en_to_os <- function(en) {
  # convert 2-column matrix of eastings/northings to alphanumeric OX grid references
  lookup <- data.frame(
    N = c("H", "H", "H", "H", "H", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "T", "T", "T", "T", "T", "T", "T", "T"),
    E = c("P", "T", "U", "Y", "Z", "A", "B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "O", "R", "S", "T", "U", "W", "X", "Y", "Z", "C", "D", "E", "H", "J", "K", "M", "N", "O", "P", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "A", "F", "G", "L", "M", "Q", "R", "V"),
    X = c(4, 3, 4, 3, 4, 0, 1, 2, 3, 0, 1, 2, 3, 4, 0, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 2, 3, 4, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 0, 1, 2, 3, 4, 5, 5, 6, 5, 6, 5, 6, 5),
    Y = c(12, 11, 11, 10, 10, 9, 9, 9, 9, 8, 8, 8, 8, 8, 7, 7, 7, 7, 6, 6, 6, 6, 5, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 4, 3, 3, 2, 2, 1, 1, 0)
  )
  # get numbers for squares
  squarenums <- floor(en / 100000)
  # convert to letters
  squares <- apply(squarenums, 1, function(x) {
    idx <- which(lookup[, 3] == x[1] & lookup[, 4] == x[2])
    paste(lookup[idx, 1], lookup[idx, 2], sep = "")
  })
  # get Eastings/ Northings w/in square, to nearest meter
  nums <- round(en - squarenums * 100000) # to nearest metre
  # remove trailing 0s
  nums <- t(apply(nums, 1, function(x) {
    x / 10^(which(sapply(1:6, function(i, x) any(x %% 10^i != 0), x))[1] - 1)
  }))

  gridrefs <- cbind(squares, nums)
  apply(gridrefs, 1, paste, collapse = "")
}
