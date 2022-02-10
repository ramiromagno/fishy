#' Euclidean or Great Circle distance between points
#'
#' @description
#' The function returns a vector of distances between a single 2D point
#' (`pts_x`, `pts_y`) and a set of 2D points, provided as two `double`
#' vectors, `pts_x` and `pts_y`.
#'
#' The distance calculation can be either the Great Circle distance  (WGS84
#' ellipsoid, `longlat = TRUE`), or the Euclidean distance (`longlat = FALSE`).
#'
#' @details
#' This function is a thin R wrapper around the C function `fishy_dists`. This
#' function performs no checking on the input, and arguments are passed down
#' to the C implementation as is. This means you should not use this function
#' if you do not know what you are doing.
#'
#' @param pt_x A `double` scalar, the longitude of the single point.
#' @param pt_y A `double` scalar, the latitude of the single point.
#' @param pts_x A `double` vector, the longitude of the set of the other points.
#' @param pts_y A `double` vector, the latitude of the set of the other points.
#' @param longlat A `logical` scalar indicating whether to calculate the Great
#'   Circle (WGS84 ellipsoid) distance (`TRUE`) or the Euclidean distance
#'   (`FALSE`).
#' @return A `double` vector of distances in the original metric of the points.
#'
#' @note The code is based on the source of [sp::spDistsN1]. We adapted and
#'   included [sp::spDistsN1] in this package because of two reasons: (i) to
#'   avoid a dependency to sp, as this is the only function used from that
#'   package; and (ii) to adapt its prototype to accept vectors instead of
#'   matrices, as that fitted better in our workflow.
#'
#' @md
#' @keywords internal
spDistsN1 <- function(pt_x, pt_y, pts_x, pts_y, longlat = TRUE) {
  n <- as.integer(length(pts_x))
  dists <- vector(mode = "double", length = n)

  # The subsetting at 6 indicates that we want to return the sixth argument
  # passed to `.C()`, i.e. `dists`.
  res <- .C("fishy_dists", pts_x, pts_y, pt_x, pt_y, n, dists, longlat, PACKAGE = "fishy")[[6]]

  if (any(!is.finite(res))) {
    nAn <- which(!is.finite(res))
    dx <- abs(pts_x[nAn] - pt_x)
    dy <- abs(pts_y[nAn] - pt_y)
    if (all((c(dx, dy) < .Machine$double.eps^0.5)))
      res[nAn] <- 0
    else stop(paste("non-finite distances in spDistsN1"))
  }

  res
}
