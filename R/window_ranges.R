#' @export
window_ranges <- function(n, start, window = 1, na_rm = FALSE) {

  if(n < 1) stop('`n` must be greater than one.')
  if(start < 1) stop('`start` must be greater than one.')
  if(start > n) stop('`start` must be less than or equal to `n`.')
  if(window < 1) stop('`window` must be equal or greater than one.')

  i <- seq_len(n)
  from<- i + start - 1
  to <- pmin(from + window - 1, n)

  # Update first `e` and then `s` because we need the old version of `s`, not
  # the updated version.
  if(na_rm) {
    to <- to[!(from > n)]
    from <- from[!(from > n)]
  } else {
    to[from > n] <- NA_integer_
    from[from > n] <- NA_integer_
  }

  m <- matrix(c(from, to), ncol = 2)
  colnames(m) <- c('from', 'to')

  return(m)
}
