setup_dt <- function(df, time_col) {
  dt <- data.table::as.data.table(df)
  dt[['..id..']] <- as.numeric(seq.int(nrow(dt)))
  data.table::setkeyv(dt, c(time_col))
}

#' Find overlap between vessel track points
#'
#' Find overlap between vessel track points.
#' **Note: this function is highly experimental and still needs to be
#' documented.**
#'
#' @param df A data frame consisting of a time series. Each observation is a point in time. The time points must be evenly spaced.
#' @param time_range A time range, in the form of a two-element vector.
#' @param speed_range A vessel speed range, also in the form of a two-element vector.
#' @param time_col A string indicating the name of the column that contains the time values.
#' @param speed_col A string indicating the name of the column that contains the speed values.
#' @param lon_col A string indicating the name of the column that contains the longitude values.
#' @param lat_col A string indicating the name of the column that contains the latitude values.
#'
#' @return A [tibble][tibble::tibble-package] whose observations are the closest
#'   points, i.e., the first row contains information about the point closest to
#'   the first, the second row, about the point closest to the second, and so
#'   on. These are the columns:
#' \describe{
#' \item{`arg_min_dist`}{The index of closest point.}
#' \item{`min_dist`}{The distance to the closest point.}
#' }
#'
#' @md
#' @export
find_overlap <-
  function(df,
           time_range,
           speed_range,
           time_col = 'DATE',
           speed_col = 'SPE',
           lon_col = 'LON',
           lat_col = 'LAT') {

    n_row <- nrow(df)
    # dt <- setup_dt(df, time_col = time_col)
    dt <- data.table::as.data.table(df)
    dt[['..id..']] <- seq.int(nrow(dt))
    data.table::setkeyv(dt, c(time_col))

    t_lower <- as.data.frame(dt[ , time_col, with = FALSE])[, 1] + time_range[1]
    t_upper <- as.data.frame(dt[ , time_col, with = FALSE])[, 1] + time_range[2]

    arg_min_dist <- rep(NA_integer_, length = n_row)
    min_dist <- rep(NA_real_, length = n_row)

    for (i in seq_len(n_row)) {

      dt_subset <-
        dt[dt[[time_col]] >= t_lower[i] &
             dt[[time_col]] < t_upper[i] &
             dt[[speed_col]] >= speed_range[1] &
             dt[[speed_col]] < speed_range[2], c('..id..', lon_col, lat_col), with = FALSE]

      if (nrow(dt_subset) > 0) {
        distances <- spDistsN1(pt_x = dt[[lon_col]][i],
                               pt_y = dt[[lat_col]][i],
                               pts_x = dt_subset[[lon_col]],
                               pts_y = dt_subset[[lat_col]],
                               longlat = TRUE)

        iii <- which.min(distances)
        if (length(iii) > 0) {
          arg_min_dist[i] <- dt_subset[iii, '..id..']
          min_dist[i] <- distances[iii]
        }
      }
    }

    return(cbind(dt, arg_min_dist, min_dist))

  }

#' #' @export
#' find_overlap_old <-
#'   function(df,
#'            time_range,
#'            speed_range,
#'            time_col = 'DATE',
#'            speed_col = 'SPE',
#'            lon_col = 'LON',
#'            lat_col = 'LAT') {
#'     n_row <- nrow(df)
#'     m <- as.matrix(df[c(lon_col, lat_col)])
#'
#'     # Because the time series is evenly spaced we can derive a time step
#'     delta_t <- df[2, time_col] - df[1, time_col]
#'
#'     # Indices corresponding to the time interval indicated in `time_range`
#'     i_range <- as.integer(time_range / delta_t) + 1
#'     ranges <-
#'       index_ranges(
#'         n = n_row,
#'         start = i_range[1],
#'         window = i_range[2] - i_range[1] + 1,
#'         na_rm = TRUE
#'       )
#'
#'     speed_condition <-
#'       df[[speed_col]] >= speed_range[1] &
#'       df[[speed_col]] < speed_range[2]
#'
#'     arg_min_dist <- rep(NA_integer_, length = n_row)
#'     min_dist <- rep(NA_real_, length = n_row)
#'
#'     for (i in seq_len(nrow(ranges))) {
#'       ii <- intersect3(ranges[i, ], speed_condition)
#'       distances <- sp::spDistsN1(pt = m[i, ],
#'                                  pts = m[ii, , drop = FALSE],
#'                                  longlat = TRUE)
#'
#'       iii <- which.min(distances)
#'       if (length(iii) > 0) {
#'         arg_min_dist[i] <- ii[iii]
#'         min_dist[i] <- distances[iii]
#'       }
#'     }
#'
#'     return(tibble::tibble(arg_min_dist, min_dist))
#'
#'   }
