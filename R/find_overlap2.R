#' #' Find overlap between vessel track points
#' #'
#' #' Find overlap between vessel track points.
#' #' **Note: this function is highly experimental and still needs to be
#' #' documented.**
#' #'
#' #' @param df A data frame consisting of a time series. Each observation is a point in time. The time points must be evenly spaced.
#' #' @param time_range A time range, in the form of a two-element vector.
#' #' @param speed_range A vessel speed range, also in the form of a two-element vector.
#' #' @param time_col A string indicating the name of the column that contains the time values.
#' #' @param speed_col A string indicating the name of the column that contains the speed values.
#' #' @param lon_col A string indicating the name of the column that contains the longitude values.
#' #' @param lat_col A string indicating the name of the column that contains the latitude values.
#' #' @param keep_self When looking for neighbouring points that fall within the
#' #'   time and speed ranges, this flag indicates whether to keep the point itself
#' #'   in this search `keep_self = TRUE` or to remove it `keep_self = FALSE`
#' #'   (default).
#' #'
#' #' @return A [tibble][tibble::tibble-package] whose observations are the closest
#' #'   points, i.e., the first row contains information about the point closest to
#' #'   the first, the second row, about the point closest to the second, and so
#' #'   on. These are the columns:
#' #' \describe{
#' #' \item{`arg_min_dist`}{The index of closest point.}
#' #' \item{`min_dist`}{The distance to the closest point.}
#' #' }
#' #'
#' #' @md
#' #' @export
#' find_overlap2 <- function(df,
#'                           time_range,
#'                           speed_range,
#'                           time_col = 'DATE',
#'                           speed_col = 'SPE',
#'                           lon_col = 'LON',
#'                           lat_col = 'LAT',
#'                           keep_self = FALSE) {
#'
#'   data.table::setDT(df)
#'
#'   # create the id and the lower and upper bounds
#'   df[,`:=`(
#'     id =.I,
#'     tlower = DATE+time_range[1], tupper=DATE+time_range[2],
#'     slower = speed_range[1], supper=speed_range[2])]
#'
#'   sdf = df[df, on = .(DATE >= tlower,
#'                       DATE <= tupper,
#'                       SPE >= slower,
#'                       SPE <= supper)][, .(
#'                         DATE = i.DATE,
#'                         SPE = i.SPE,
#'                         close_LAT = LAT,
#'                         close_LON = LON,
#'                         close_id = id,
#'                         id = i.id,
#'                         LAT = i.LAT,
#'                         LON = i.LON
#'                       )]
#'
#'   sdf <- sdf[df, on = .(id)]
#'
#'   # sdf[,distance:=sqrt((LAT-close_LAT)^2  + (LON-close_LON)^2)]
#'   sdf[, distance := geosphere::distMeeus(p1 = matrix(c(LON, LAT), ncol = 2),
#'                                          p2 = matrix(c(close_LON, close_LAT), ncol = 2))]
#'
#'   # sdf <- sdf[order(id,distance)][id!=close_id][,.SD[1], by=id][,.(id,closest = close_id, distance)]
#'   if(keep_self) {
#'     sdf <- sdf[order(id,distance)][,.SD[1], by=id][,.(id, arg_min_dist = close_id, min_dist = distance)]
#'   } else {
#'     sdf <- sdf[order(id,distance)][id!=close_id][,.SD[1], by=id][,.(id, arg_min_dist = close_id, min_dist = distance)]
#'   }
#'
#'   # geosphere::distMeeus returns distance in metres, we convert to km by dividing by 1000.
#'   df[sdf, on=.(id)][, c("tlower","tupper", 'slower', 'supper'):=NULL][, min_dist := min_dist / 1000]
#'
#' }
#'
#' #' @export
#' find_overlap3 <- function(df,
#'                           time_range,
#'                           speed_range,
#'                           time_col = 'DATE',
#'                           speed_col = 'SPE',
#'                           lon_col = 'LON',
#'                           lat_col = 'LAT',
#'                           keep_self = FALSE) {
#'
#'   data.table::setDT(df)
#'
#'   df[,`:=`(
#'     tlower = DATE+time_range[1], tupper=DATE+time_range[2],
#'     slower = speed_range[1], supper=speed_range[2])][, id := 1:.N, by = mmsi]
#'
#'   sdf = df[df, on = .(mmsi, DATE >= tlower,
#'                       DATE <= tupper,
#'                       SPE >= slower,
#'                       SPE <= supper)][, .(
#'                         mmsi,
#'                         DATE = i.DATE,
#'                         SPE = i.SPE,
#'                         close_LAT = LAT,
#'                         close_LON = LON,
#'                         close_id = id,
#'                         id = i.id,
#'                         LAT = i.LAT,
#'                         LON = i.LON
#'                       )]
#'
#'   sdf <- sdf[df, on = .(mmsi, id)]
#'
#'   sdf[, distance := geosphere::distMeeus(p1 = matrix(c(LON, LAT), ncol = 2),
#'                                          p2 = matrix(c(close_LON, close_LAT), ncol = 2)), by = mmsi]
#'
#'   if(keep_self) {
#'     sdf <- sdf[order(mmsi, id, distance)][,.SD[1], by=.(mmsi, id)][,.(mmsi, id, arg_min_dist = close_id, min_dist = distance)]
#'   } else {
#'     sdf <- sdf[order(mmsi, id, distance)][id!=close_id][,.SD[1], by=.(mmsi, id)][,.(mmsi, id, arg_min_dist = close_id, min_dist = distance)]
#'   }
#'
#'   sdf <- sdf[df, on=.(mmsi, id)][, c("tlower","tupper", 'slower', 'supper'):=NULL][, min_dist := min_dist / 1000]
#'
#'   return(sdf)
#' }

#' #' @export
#' find_overlap2 <- function(df,
#'                           time_range,
#'                           speed_range,
#'                           time_col = 'DATE',
#'                           speed_col = 'SPE',
#'                           lon_col = 'LON',
#'                           lat_col = 'LAT') {
#'
#'   setDT(df, key = c(time_col))
#'
#'   # create the id and the lower and upper bounds
#'   df[,`:=`(
#'     id =.I,
#'     tlower = DATE+time_range[1], tupper=DATE+time_range[2],
#'     slower = speed_range[1], supper=speed_range[2])]
#'
#'   # merge df on itself, using non-equi join and rename cols as needed
#'   sdf = df[df, on = .(DATE >= tlower,
#'                       DATE <= tupper,
#'                       SPE >= slower,
#'                       SPE <= supper)][, .(
#'                         DATE,
#'                         SPE,
#'                         LAT,
#'                         LON,
#'                         id,
#'                         close_id = i.id,
#'                         close_LAT = i.LAT,
#'                         close_LON = i.LON
#'                       )]
#'
#'   # get the distance
#'   # sdf[,distance:=sqrt((LAT-close_LAT)^2  + (LON-close_LON)^2)]
#'   sdf[, distance := geosphere::distMeeus(p1 = matrix(c(LON, LAT), ncol = 2),
#'                                          p2 = matrix(c(close_LON, close_LAT), ncol = 2)) / 1000.]
#'
#'   # get the datatable with the closest id
#'   # sdf <- sdf[order(id,distance)][id!=close_id][,.SD[1], by=id][,.(id,closest = close_id, distance)]
#'   sdf <- sdf[order(id,distance)][,.SD[1], by=id][,.(id,closest = close_id, distance)]
#'
#'
#'   # merge back on original
#'   sdf[df[,.(id)], on=.(id)]
#'   # df[sdf, on=.(id)]
#'   # return(merge(sdf, df, by = 'id', all.x = TRUE))
#'
#' }
