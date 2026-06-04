vspan_pulse <- function(pulse, alpha = 0.15) {
  list(
    geom_rect(
      data = pulse,
      aes(xmin = date_start, xmax = date_peak, ymin = -Inf, ymax = Inf),
      fill = "blue", alpha = alpha, inherit.aes = FALSE
    ),
    geom_rect(
      data = pulse,
      aes(xmin = date_peak, xmax = date_end, ymin = -Inf, ymax = Inf),
      fill = "red", alpha = alpha, inherit.aes = FALSE
    )
  )
}

vspan_day <- function(day, alpha = 0.15) {
  geom_rect(
    data = day,
    aes(xmin = time_beg, xmax = time_end, ymin = -Inf, ymax = Inf),
    fill = "red", alpha = alpha, inherit.aes = FALSE
  )
}
