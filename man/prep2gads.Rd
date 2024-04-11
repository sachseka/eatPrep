\name{prep2GADS}
\alias{prep2GADS}

\title{Convert eatPrep Data and Meta Info to eatGADS Object, i.e., \code{GADSdat} object
}
\description{This function converts a data.frame with data that have been prepared for IRT analyses with eatPrep to an eatGADS object.
}
\usage{
prep2GADS(dat, inputList, trafoType = c("scored", "raw"),
misTypes = list(mvi = -95, mnr = -96, mci = -97, mbd = -94, mir = -98, mbi = -99),
verbose = TRUE)
}
\arguments{
  \item{dat}{A data.frame, typically one in the last transformation status after eatPrep-based transformations (after 'scoring'). However, recoded and aggregated, but not scored data can also be handled, as long as this data.frames' colnames correspond to the unit-names \code{'units'} in the \code{inputList} (that is \code{trafoType=="scored")}. Merged but not recoded, not aggregated and not scored data can also be converted to a \code{GADSdat} object (that is \code{trafoType=="raw")}.}
  \item{inputList}{A list following the typical structure of an eatPrep inputList. Only the first three data frames are needed to utilize this function. See \sQuote{Details}.}
      \item{trafoType}{Character string. Whether raw data (including original values and subunits) or scored data (usually 0/1 and mistypes like mbi et al. and everything aggregated to units) shall be exported.}
    \item{misTypes}{
A named list with definitions how to recode the different types of missings (mainly used when \code{trafoType=="scored")}.}
  \item{verbose}{logical. If \code{TRUE}, additional information is printed.}
}
\details{
This function converts a recoded, aggregated and scored data set to an \code{eatGADS} object using the meta information stored in an \code{inputList}. Only the first three data.frames of a typical \code{inputList} are used (\code{subunits}, \code{values} and \code{units}). However, the order of these three data.frames in the inputList is irrelevant.

Examples of data frames \code{subunits}, \code{values} and \code{units} can be found via \code{data(\link{inputList})}.

}
\value{
A \code{GADSdat} object.
}
\author{
Karoline Sachse
}
\examples{
data(inputDat)
data(inputList)

prepDatScored <- automateDataPreparation(inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData=FALSE, mergeData = TRUE, recodeData=TRUE,
    aggregateData=TRUE, scoreData=TRUE, writeSpss=FALSE, verbose = TRUE)

GADSobj1 <- prep2GADS(dat = prepDatScored, inputList = inputList[1:3], trafoType = "scored",
                                verbose=TRUE)

prepDatRaw <- automateDataPreparation(inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData=FALSE, mergeData = TRUE, recodeData=FALSE,
    aggregateData=FALSE, scoreData=FALSE, writeSpss=FALSE, verbose = TRUE)

GADSobj2 <- prep2GADS(dat = prepDatRaw, inputList = inputList[1:3], trafoType = "raw",
                                verbose=TRUE)

}
