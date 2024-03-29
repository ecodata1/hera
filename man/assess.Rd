% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/assess.R
\name{assess}
\alias{assess}
\title{Assess}
\usage{
assess(data = NULL, name = NULL, catalogue = NULL)
}
\arguments{
\item{data}{Dataframe of variables in hera inter-change format}

\item{name}{Name of the assessment to be used}

\item{catalogue}{Dataframe of model_dataframe see `catalogue`}
}
\value{
Dataframe of assessments
}
\description{
Run assessment
}
\details{
\code{assess()} assess
}
\examples{
\dontrun{
assessments <- assess(hera::demo_data)
}
}
