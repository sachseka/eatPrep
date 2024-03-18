\name{prep2gads}
\alias{prep2gads}

\title{Convert eatPrep Data and Meta Info to eatGADS Object
}
\description{This function converts a data.frame with data that has been prepared for IRT analyses with eatPrep to an eatGADS object.
}
\usage{
prep2gads(dat, inputList, verbose = TRUE)
}
\arguments{
  \item{dat}{A data frame, typically one in the last transformation status after eatPrep-based transformations (after 'scoring'). However, recoded and aggregated, but not scored data can also be handled, as long as this data.frames' colnames correspond to the unit-names \code{'units'} in the \code{inputList}.}
  \item{inputList}{A list following the typical structure of an eatPrep inputList. Only the first three data frames are needed to use this function's functionality. See \sQuote{Details}.}
  \item{verbose}{logical. If \code{TRUE} additional information is printed.}
}
\details{
This function converts a recoded, aggregated and scored data set to an \code{eatGADS} object using the meta information stored in an \code{inputList}. Only the first three data.frames of a typical \code{inputList} are used (\code{subunits}, \code{values} and \code{units}).

Examples of data frames \code{subunits}, \code{values} and \code{units} can be found via \code{data(\link{inputList})}.

}
\value{
A \code{prepGADS} object that can be imported to eatGADS using \code{eatGADS::import_raw2(prepGADS$dat, prepGADS$labels)}
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

prepGADS <- prep2gads(dat = prepDat, units = inputList$units, subunits = inputList$subunits,
    values = inputList$values)

}
