#' @export
index_ranges <- function(n, start, window = 1, na_rm = FALSE) {

  i <- seq_len(n)
  from <- pmax(i + start - 1, 1)
  to <- pmin(i + start + window - 1, n)
  lgl <- from > n | to < 1

  if(na_rm) {
    from <- from[!lgl]
    to <- to[!lgl]
  } else {
    from[lgl] <- NA_integer_
    to[lgl] <- NA_integer_
  }

  m <- matrix(c(from, to), ncol = 2)
  colnames(m) <- c('from', 'to')

  return(m)
}
