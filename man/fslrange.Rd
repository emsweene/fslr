% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/fslhd.R
\name{fslrange}
\alias{fslrange}
\title{Get range of an image}
\usage{
fslrange(file, verbose = TRUE, ...)
}
\arguments{
\item{file}{(character) filename of image to be checked}

\item{verbose}{(logical) print out command before running}

\item{...}{options passed to \code{\link{checkimg}}}
}
\value{
numeric vector of length 2
}
\description{
This function calls \code{fslstats -R} to get the range of an image
}
\examples{
if (have.fsl()){
 mnifile = file.path(fsldir(), "data", "standard",
   "MNI152_T1_2mm.nii.gz")
 fslrange(mnifile)
}
}

