test_that("spDistsN1: basic", {

  d1 <- spDistsN1(pt_x = 0., pt_y = 0., pts_x = 0., pts_y = 0., longlat = TRUE)
  d2 <- spDistsN1(pt_x = 0., pt_y = 0., pts_x = 0., pts_y = 0., longlat = FALSE)

  expect_equal(d1, 0)
  expect_equal(d2, 0)
})

test_that("spDistsN1: basic 2", {

  d1 <- spDistsN1(pt_x = 1., pt_y = 1., pts_x = 1., pts_y = 1., longlat = TRUE)
  d2 <- spDistsN1(pt_x = 1., pt_y = 1., pts_x = 1., pts_y = 1., longlat = FALSE)

  expect_equal(d1, 0)
  expect_equal(d2, 0)
})

test_that("fishy::spDistsN1() vs sp::spDistsN1()", {

  # longitudes
  x <- as.double(seq(-180, 180, length.out = 10))

  # latitudes
  y <- as.double(seq(-90, 90, length.out = 10))

  # A matrix of 2D points
  pts <- as.matrix(expand.grid(x, y))
  pts_x <- pts[, 1]
  pts_y <- pts[, 2]

  pt_x <- 0.
  pt_y <- 0.
  pt <- c(pt_x, pt_y)

  d1_eucl <- spDistsN1(pt_x = pt_x, pt_y = pt_y, pts_x = pts_x, pts_y = pts_y, longlat = FALSE)
  d2_eucl <- sp::spDistsN1(pts = pts, pt = pt, longlat = FALSE)

  d1_WGS84 <- spDistsN1(pt_x = pt_x, pt_y = pt_y, pts_x = pts_x, pts_y = pts_y, longlat = TRUE)
  d2_WGS84 <- sp::spDistsN1(pts = pts, pt = pt, longlat = TRUE)

  expect_equal(d1_eucl, d2_eucl)
  expect_equal(d1_WGS84, d2_WGS84)

})
