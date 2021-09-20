\name{prep2gads}
\alias{prep2gads}

\title{Convert eatPrep Data and Meta Info to eatGADS Object
}
\description{This function converts a data.frame with data that has been prepared for IRT analyses with eatPrep to an eatGADS object.
}
\usage{
prep2gads(dat, units, subunits, values, verbose = TRUE)
}
\arguments{
  \item{dat}{A data frame, typically one in the last transformation status after eatPrep based transformations.}
  \item{units}{A data frame with unit information. See \sQuote{Details}.}
  \item{subunits}{A data frame with subunit information. See \sQuote{Details}.}
    \item{values}{A data frame with code information. See \sQuote{Details}.}
  \item{verbose}{logical. If \code{TRUE} additional information is printed.}
}
\details{
This function converts a recoded, aggregated and scored data set to an \code{eatGADS} object using the meta information stored in \code{inputList}.

Examples of data frames \code{subunits}, \code{values} and \code{units} can be found via \code{data(\link{inputList})}.

}
\value{
An \code{eatGADS} object.
}
\author{
Karoline Sachse
}
\examples{
data(inputDat)
data(inputList)

prepDat <- automateDataPreparation (inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData=FALSE, mergeData = TRUE, recodeData=TRUE,
    aggregateData=TRUE, scoreData= FALSE, writeSpss=FALSE, verbose = TRUE)

eatGADSobj <- prep2gads(dat = prepDat, units = inputList$units, subunits = inputList$subunits,
    values = inputList$values)

str(eatGADSobj)

}
