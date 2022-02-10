#' #' Determine index ranges
#' #'
#' #' This function determines ranges (i.e., `from` and `to` positions) for windows
#' #' of size `window`. `n` specifies the number of windows. The ranges are clipped
#' #' to the interval \[`1`, `n`\].
#' #'
#' #' @param n Number of windows.
#' #' @param start Starting position of the first window.
#' #' @param window Window size.
#' #' @param na_rm A logical indicating whether to remove invalid ranges (i.e.,
#' #'   whether to keep `from` and `to` as `NA`) or otherwise.
#' #'
#' #' @return A matrix of ranges (`from` and `to`), each row pertains to a range.
#' #'
#' #' @examples
#' #' index_ranges(10, start = 2, window = 3)
#' #'
#' #' index_ranges(10, start = 2, window = 3, na_rm = TRUE)
#' #'
#' #' index_ranges(10, start = -4, window = 3)
#' #'
#' #' @md
#' #' @export
#' #' @export
#' index_ranges <- function(n, start, window = 1, na_rm = FALSE) {
#'
#'   i <- seq_len(n)
#'   from <- pmax(i + start - 1, 1)
#'   to <- pmin(i + start + window - 1, n)
#'   lgl <- from > n | to < 1
#'
#'   if(na_rm) {
#'     from <- from[!lgl]
#'     to <- to[!lgl]
#'   } else {
#'     from[lgl] <- NA_integer_
#'     to[lgl] <- NA_integer_
#'   }
#'
#'   m <- matrix(c(from, to), ncol = 2)
#'   colnames(m) <- c('from', 'to')
#'
#'   return(m)
#' }
