% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/season.R
\name{season}
\alias{season}
\title{Calculate Season from Date}
\usage{
season(
  dates,
  winter = "2012-12-1",
  spring = "2012-3-1",
  summer = "2012-6-1",
  autumn = "2012-9-1",
  output = "numeric"
)
}
\arguments{
\item{dates}{List of dates with class of Date}

\item{winter}{Winter's start date}

\item{spring}{Spring's start date}

\item{summer}{Summer's start date}

\item{autumn}{Autumn's start date}

\item{output}{Options: numeric, shortname, fullname}
}
\value{
List of seasons as numbers based on seasons required for RICT. Broadly
the sampling 'seasons' used for routine sampling
}
\description{
Calculate Season from Date
}
\examples{
\dontrun{
season <- season(Sys.Date())
}
}
