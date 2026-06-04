# theta_obs ~ (theta_0 - theta_r) * exp(-t / tau) + theta_r,
# \frac{d\theta}{dt} = -k (\theta(t) - \theta_r) = -k\theta(t) + k\theta_r
fit_pdv <- function(dy, y_mean) {
  # sm <- na.omit(sm)
  r <- list(n = length(dy), tau = NA_real_, theta_r = NA_real_, r2 = NA_real_, pvalue_tau = NA_real_)
  if (length(dy) < 3) return(r)
  # dy <- diff(sm)
  # y_mean <- (sm[-1] + sm[-length(sm)]) / 2

  # 捕获异常，保障流式处理的健壮性
  tryCatch({
    fit <- lm(dy ~ y_mean)
    a <- coef(fit)["y_mean"]
    b <- coef(fit)["(Intercept)"]

    # 物理约束校验：斜率 a 必须小于 0 (处于衰减期)
    # print2(a, b)
    # if (is.na(a) || a >= 0) return(r)
    pvalue_tau <- summary(fit)$coefficients[2, 4] # [2, 4] 表示第 2 行 (x变量) 的第 4 列 (Pr(>|t|))

    list(
      theta_r    = unname(-b / a),
      n          = length(dy), 
      tau        = unname(-1.0 / a),
      pvalue_tau = unname(pvalue_tau), 
      r2         = summary(fit)$r.squared
    )
  }, error = function(e) {
    r
  })
}

# # 2. 提取整个模型的 F 检验 p-value
# f_stat <- summary(fit)$fstatistic
# pvalue_f <- pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE)
# # pf() 用于计算 F 分布的累积概率，lower.tail = FALSE 表示计算上侧尾部面积 (即 p-value)
fit_nls <- function(t, sm) {
  start_list <- list(theta_0 = sm[1], theta_r = 10.0, tau = 10.0)
  fit <- nls(
    sm ~ (theta_0 - theta_r) * exp(-t / tau) + theta_r,
    start = start_list
  )

  ypred = predict(fit)
  gof = GOF(sm, ypred)
  pvalue = broom::tidy(fit)
  c(n = length(t), coef(fit), pvalue_tau = pvalue$p.value[3], r2 = gof$R2) %>% as.list()
}

# 该方法解释方差比例最高
fit_norm <- function(t, sm_norm) {
  fit <- lm(log(sm_norm) ~ 0 + t) # 强制过原点
  pred <- predict(fit, newdata = data.frame(t = t)) %>% exp() # 还原到原始空间
  gof = gg.layers::GOF(log(sm_norm), log(pred))

  s = summary(fit)
  tau = unname(-1 / coefficients(fit))
  pvalue = s$coefficients[4]
  # pred = pred, gof = gof,
  list(n = length(t), tau = tau, pvalue_tau = pvalue, r2 = s$r.squared)
}
