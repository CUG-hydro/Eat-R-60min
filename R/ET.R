# Inputs: Loss, has_prcp, slope_night, slope_day
#' @import data.table
add_slope_flag <- function(d) {
  # 假设 d 是 data.table 格式
  d[, flag := fcase(
    # 优先级 1：先剔除所有降水和净增水事件 (您的 good2)
    Loss < 0 | has_prcp == TRUE, "Recharge",

    # 优先级 2：在非降水天中，抓取夜间失水异常的伪影数据 (您的 bad)
    slope_night < 0 & (-slope_day < -slope_night), "TempError",

    # 优先级 3：在剩余数据中，白天耗水大于夜间耗水，即真实的 ET 驱动 (您的 good1)
    -slope_day > -slope_night, "Normal",

    # 兜底：不满足上述任何条件 (等于您的 others)
    default = "Others"
  )] %>% invisible()
  relocate(d, date, SM_median, has_prcp, flag)
}
