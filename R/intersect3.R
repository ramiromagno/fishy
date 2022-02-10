#' #' Intersect a sequence and a logical vector
#' #'
#' #' This function intersects a sequence, i.e. an sequential integer vector with a
#' #' logical vector `lgl`. The sequence `range` is provided as an interval in the
#' #' form of a two element vector with start and end indices.
#' #'
#' #' @param range A two-element integer vector.
#' #' @param lgl A logical vector.
#' #'
#' #' @return An integer vector.
#' #' @examples
#' #' intersect3(range = c(2, 4), lgl = c(FALSE, TRUE, FALSE, TRUE, TRUE))
#' #'
#' #' @md
#' #' @export
#' intersect3 <- function(range, lgl) {
#'
#'   i <- range[1]:range[2]
#'   i[lgl[i]]
#'
#' }
