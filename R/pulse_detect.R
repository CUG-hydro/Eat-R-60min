library(data.table)

# 土壤水分快速上升（超过0.01），且之后至少连续4天下降的事件被定义为一个脉冲事件。
mark_rise <- function(d, threshold = 0.01) {
  c(FALSE, diff(d) > threshold)
}

# 从当前位置起，之后连续下降的天数
count_decrease_streak <- function(d) {
  dec <- c(FALSE, diff(d) < 0)
  n <- length(d)
  streak <- integer(n)
  for (j in (n - 1L):1L) {
    streak[j] <- if (dec[j + 1L]) streak[j + 1L] + 1L else 0L
  }
  streak
}

# 到达当前位置时，之前连续上涨的天数（含当天）
count_rise_streak <- function(d, threshold = 0.01) {
  rise <- c(FALSE, diff(d) > threshold)
  n <- length(d)
  streak <- integer(n)
  for (j in 2L:n) {
    streak[j] <- if (rise[j]) streak[j - 1L] + 1L else 0L
  }
  streak
}

detect_pulses <- function(SM, dates, threshold = 0.01, min_decrease = 4) {
  n <- length(SM)

  rise <- mark_rise(SM, threshold)
  streak_decrease <- count_decrease_streak(SM)
  streak_rise <- count_rise_streak(SM, threshold)

  idx <- which(rise & streak_decrease >= min_decrease) # 脉冲
  if (length(idx) == 0L) {
    return(data.table())
  }

  pulse <- data.table(
    date_start = dates[idx - streak_rise[idx]], # 起涨前一天
    date_peak  = dates[idx],
    date_end   = dates[pmin(idx + streak_decrease[idx], n)],
    sm_base    = SM[idx - streak_rise[idx]],
    sm_peak    = SM[idx],
    delta_rise = SM[idx] - SM[idx - streak_rise[idx]],
    n_dry_days = streak_decrease[idx]
  )
  # slope <- pulse_slope(SM, dates, pulse)
  pulse
}

# 提取每个脉冲的数据子集
subset_data <- function(SM, dates, pulse) {
  index <- 1:nrow(pulse) %>% set_names(., .)
  res <- foreach(i = index, i = icount()) %do% {
    date_peak <- pulse$date_peak[i]
    date_end <- pulse$date_end[i]
    I <- which(dates >= date_peak & dates <= date_end) # drydown过程的索引

    sm <- SM[I]
    dy <- diff(sm)
    y_mean <- (sm[-1] + sm[-length(sm)]) / 2

    data.table(
      group = i,
      date = dates[I], sm = SM[I],
      tau = seq_along(I) - 1,       # 从0开始计数, 表示从峰值开始的天数
      dy = c(NA, dy), y_mean = c(NA, y_mean), sm_norm = sm / sm[1]
    )
  }
  do.call(rbind, res)
}

pulse_slope <- function(SM, dates, pulse) {
  foreach(i = 1:nrow(pulse), i = icount(), .combine = rbind) %do% {
    date_peak <- pulse$date_peak[i]
    date_end <- pulse$date_end[i]
    inds <- which(dates >= date_peak & dates <= date_end)

    y <- SM[inds]
    t1 <- slope_mk(y)
    t2 <- fit_decay(y)
    c(t1, t2)
  } %>% as.data.table()
}
