% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/fslhd.R
\name{fslmerge}
\alias{fslmerge}
\title{Merge images using FSL}
\usage{
fslmerge(infiles, direction = c("x", "y", "z", "t", "a"), outfile = NULL,
  retimg = FALSE, reorient = FALSE, intern = TRUE, verbose = TRUE, ...)
}
\arguments{
\item{infiles}{(character) input filenames}

\item{direction}{(character) direction to merge over, x, y, z,
t (time), a (auto)}

\item{outfile}{(character) output filename}

\item{retimg}{(logical) return image of class nifti}

\item{reorient}{(logical) If retimg, should file be reoriented when read in?
Passed to \code{\link{readNIfTI}}.}

\item{intern}{(logical) pass to \code{\link{system}}}

\item{verbose}{(logical) print out command before running}

\item{...}{additional arguments passed to \code{\link{readNIfTI}}.}
}
\value{
character or logical depending on intern
}
\description{
This function calls \code{fslmerge} to merge files on some dimension
and either saves the image or returns an object of class nifti
}

