
convert <- function(data, convert_to = "hera", convert_from = "sepa") {

  if(convert_to == "hera" & convert_to == "sepa") {

  names <- utils::read.csv(system.file("extdat",
                                       "column-names.csv",
                                       package = "hera")
  )


  data$taxon_id <- NA
  data$nbn_code <- as.character(data$nbn_code)
  data$taxon_id[!is.na(data$nbn_code)] <-  data$nbn_code[!is.na(data$nbn_code)]
  data$taxon_id[!is.na(data$maitland_code)] <-  data$maitland_code[!is.na(data$maitland_code)]
  data$taxon_id[!is.na(data$whitton_code)] <-  data$whitton_code[!is.na(data$whitton_code)]

  to_change <-  which(names(data) %in% names$sepa_view[names$hera_latest != ""])
  change_to <- names$hera_latest[names$sepa_view %in% names(data) & names$hera_latest != ""]
  names(data)[to_change] <- change_to
  return(data)

  } else {
    message(paste("No conversion rules created for", convert_to, "/", convert_from))
    return(NULL)
  }
}