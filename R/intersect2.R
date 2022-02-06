#' Intersect a sequence and a vector
#'
#' This function intersects a sequence, i.e. an sequential integer vector with
#' an integer vector `x`. The sequence `range` is provided as an interval in the
#' form of a two element vector with start and end indices.
#'
#' @param range A two-element integer vector.
#' @param x An integer vector.
#'
#' @return An integer vector.
#' @examples
#' intersect2(range = c(3, 8), x = c(1, 5, 10))
#'
#' @md
#' @export
intersect2 <- function(range, x) {
  x[x >= range[1] & x <= range[2]]
}
