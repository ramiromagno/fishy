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
    i_vec <- seq_len(n_row)
    m <- as.matrix(df[c(lon_col, lat_col)])

    # Because the time series is evenly spaced we can derive a time step
    delta_t <- df[2, time_col] - df[1, time_col]

    # Indices corresponding to the time interval indicated in `time_range`
    i_range <- as.integer(time_range / delta_t) + 1
    ranges <-
      window_ranges(
        n = n_row,
        start = i_range[1],
        window = i_range[2] - i_range[1] + 1,
        na_rm = TRUE
      )

    # All low speed observations
    speed_condition <-
      df[[speed_col]] >= speed_range[1] &
      df[[speed_col]] < speed_range[2]

    arg_min_dist <- rep(NA_integer_, length = n_row)
    min_dist <- rep(NA_real_, length = n_row)

    for (i in seq_len(nrow(ranges))) {
      ii <- intersect3(ranges[i, ], speed_condition)
      distances <- sp::spDistsN1(pt = m[i, ],
                             pts = m[ii, , drop = FALSE],
                             longlat = TRUE)

      iii <- which.min(distances)
      if (length(iii) > 0) {
        arg_min_dist[i] <- ii[iii]
        min_dist[i] <- distances[iii]
      }
    }

    return(tibble::tibble(arg_min_dist, min_dist))

  }
