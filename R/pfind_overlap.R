#' @importFrom data.table ".SD"
#' @export
pfind_overlap <- function(df,
                          time_range,
                          speed_range,
                          time_col = 'DATE',
                          speed_col = 'SPE',
                          lon_col = 'LON',
                          lat_col = 'LAT',
                          by = 'mmsi') {

  dt <- data.table::as.data.table(df)
  data.table::setkeyv(dt, c(by, time_col))

  j_expression <- substitute(
    find_overlap(
      df = .SD,
      time_range,
      speed_range,
      time_col,
      speed_col,
      lon_col,
      lat_col
    ),
    env = list(
      time_range = time_range,
      speed_range = speed_range,
      time_col = time_col,
      speed_col = speed_col,
      lon_col = lon_col,
      lat_col = lat_col,
      by = by
    )
  )

  dt[, j = eval(j_expression), by = by]

}
