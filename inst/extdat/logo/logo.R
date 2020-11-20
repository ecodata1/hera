

logo <- function() {
  ### Script to create logos -----------------------------------------------
  library(hexSticker)
  library(wesanderson)
  library(png)
  library(grid)

  ### darleq3 ----------------------
  # Image originally downloaded from flickr
  # https://flic.kr/p/osTFPm
  # Internet Archive Book Images
  # Image from page 668 of "The microscope and its revelations" (1901)
  # Identifier: microscopeitsrev00carp
  # Title: The microscope and its revelations
  # Year: 1901 (1900s)
  # Authors: Carpenter, William Benjamin, 1813-1885 Dallinger, W. H. (William Henry), 1842-1909
  # Subjects: Microscopy Microscopes Natural history
  # Publisher: Philadelphia, P. Blackiston's Sons and Co.
  # Contributing Library: MBLWHOI Library#
  img <- readPNG(system.file("extdat/images", "darleq.png", package = "hera"))
  g <- rasterGrob(img, interpolate = TRUE)

  sticker(g,
          package = "DARLEQ3", p_color = "#2f579a", p_x =1 , p_y = 1.1,
          p_size = 28, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#2f579a",  filename = "man/figures/darleq3_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "serif", h_fill = "#2f579a"
  )

  sticker(g,
          package = "DARLEQ3", p_color = "#2f579a", p_x =1 , p_y = 1.1,
          p_size = 28, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#2f579a",  filename = "vignettes/images/darleq3_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "serif", h_fill = "#2f579a"
  )

  sticker(g,
          package = "DARLEQ3", p_color = "#2f579a", p_x =1 , p_y = 1.1,
          p_size = 28, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#2f579a",  filename = "inst/extdat/images/darleq3_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "serif", h_fill = "#2f579a"
  )

  ### hera logo ---------------------
  # Image originally downloaded from flickr
  # https://flic.kr/p/rXeR3P
  # Bildnis des Heraclitus
  # Abgebildete Person: Heraclitus . Radierung, 1701/1800, 95 x 53 mm hera_logo(Blatt), im Bestand der Universitätsbibliothek Leipzig, Porträtstichsammlung 21/176 ( siehe auch www.portraitindex.de/documents/obj/33203495 ).
  # This work has been identified as being free of known restrictions under copyright law, including all related and neighboring rights (creativecommons.org/publicdomain/mark/1.0/). Leipzig University Library, 2015.

  img <- readPNG(system.file("extdat/images", "hera.png", package = "hera"))
  g <- rasterGrob(img, interpolate = TRUE)

  sticker(g,
          package = "hera", p_color = "#12c9cd", p_x =1 , p_y = 1.1,
          p_size = 42, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#4e4098",  filename =   "man/figures/hera_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "sans", h_fill = "#4e4098"
  )


  sticker(g,
          package = "hera", p_color = "#12c9cd", p_x =1 , p_y = 1.1,
          p_size = 42, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#4e4098",  filename =  "vignettes/images/hera_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "sans", h_fill = "#4e4098"
  )

  sticker(g,
          package = "hera", p_color = "#12c9cd", p_x =1 , p_y = 1.1,
          p_size = 42, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#4e4098",  filename = "inst/extdat/images/hera_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "sans", h_fill = "#4e4098"
  )

  # fcs2 logo ---------------------
  # Image originally downloaded from flickr
  # https://flic.kr/p/a7SXBh
  # Our country's fishes and how to know them
  # London :Simpkin, Hamilton, Kent & Co.,[1902]
  # biodiversitylibrary.org/page/20965834
  # Public domain

  img <- readPNG(system.file("extdat/images", "fcs2.png", package = "hera"))
  g <- rasterGrob(img, interpolate = TRUE)

  sticker(g,
          package = "hera", p_color = "#49ff8f", p_x =1 , p_y = 0.8,
          p_size = 42, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#49ff8f",  filename =   "man/figures/fcs2_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "sans", h_fill = "#49ff8f"
  )


  sticker(g,
          package = "hera", p_color = "#49ff8f", p_x =1 , p_y = 0.8,
          p_size = 42, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#49ff8f",  filename =  "vignettes/images/fcs2_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "sans", h_fill = "#49ff8f"
  )

  sticker(g,
          package = "FCS2", p_color = "#49ff8f", p_x =1 , p_y = 0.8,
          p_size = 42, s_x = 1, s_y = 1, s_width = 3, s_height = 3,
          h_color = "#49ff8f",  filename = "inst/extdat/images/fcs2_logo.png",
          white_around_sticker = T, l_x = 1, l_y = 0.8, spotlight = TRUE,
          p_family = "sans", h_fill = "#49ff8f"
  )

}
