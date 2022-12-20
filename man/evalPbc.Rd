\name{evalPbc}
\alias{evalPbc}

\title{evaluate discrimination statistics
}
\description{This function evaluates discrimination statistics for the categories of categorical variables, i.e. the correlations of each category with the total score on the test.
}
\usage{
evalPbc(pbcs, mistypes = c("mnr", "mbd", "mir", "mbi"),
        minPbcAtt = .05, maxPbcDis = .005, maxPbcMis = .07)
}
\arguments{
  \item{pbcs}{
A data frame with the discrimination values for each category of categorical variables: output of \code{\link{catPbc}}. The data frame contains the following columns: item, cat, n, freq, freq.rel, catPbc, recodevalue, subunitType.
}
  \item{mistypes}{
Character vector. It will be checked, whether the missing types in this vector are defined for all items.
}
  \item{minPbcAtt}{
Numeric (Optional). It will be checked, whether the catPbcs for the attractors are higher than this value. Defaults to .05.
}
  \item{maxPbcDis}{
Numeric (Optional). It will be checked, whether the catPbcs for the distractors are lower than this value. Defaults to 0.005.
}
  \item{maxPbcMis}{
Numeric (Optional). It will be checked, whether the catPbcs for the missing types are lower than this value. Defaults to 0.07.
}
}
\value{
Logical. \code{TRUE} if everything is OK, \code{FALSE} otherwise.
}
\examples{
data(inputDat)
data(inputList)

datRaw <- mergeData(newID = "ID", datList = inputDat, addMbd = TRUE)
datRec <- recodeData(datRaw, values = inputList$values,
    subunits=inputList$subunits)
pbcs   <- catPbc(datRaw, datRec, idRaw = "ID", idRec = "ID",
    context.vars = "hisei", values = inputList$values,
    subunits = inputList$subunits)
evalPbc(pbcs)
}
\author{
Karoline Sachse, Philipp Franikowski
}
