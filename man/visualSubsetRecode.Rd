\name{visualSubsetRecode}
\alias{visualSubsetRecode}
\title{Inspect data subsets visually and recode instantaneously}
\description{
This function checks whether a data frame corresponds to a particular rotated block design, i.e. whether all persons have valid codes on all items they were presented with and one consistent missing code for all items they were not presented with.}
\usage{visualSubsetRecode(dat, subsetInfo, ID, toRecodeVal="mci")}
\arguments{
  \item{dat}{A data frame}
  \item{subsetInfo}{A data frame}
  \item{id}{A character vector of length 1 indicating the name of the case identifier variable in \code{dat}. Default is \code{ID}.}
  	\item{toRecodeVal}{
	Optional: A scalar indicating recode string. }
}
}
%% \details{
%% tbd
%% }

\author{Karoline Sachse}

\examples{
data(inputDat)
data(inputList)

prepDat <- automateDataPreparation (inputList = inputList, datList = inputDat,
    readSpss = FALSE, checkData = FALSE, mergeData = TRUE, recodeData = TRUE,
    aggregateData = FALSE, scoreData = FALSE, writeSpss = FALSE, verbose = TRUE)

subsetInfoMin <- data.frame(ID=c("person100", "person101", "person102", "person103", "person101",
                                 "person100", "person101", "person102", "person103", "person101",
                                 "person101"),
                            datCols=c("I01R", "I02R", "I01R", "I01R", "I02R", "I03R",
                                      "I04R", NA, "I02R", "I03R", "I04R"))

visualSubsetRecode(dat=prepDat, subsetInfo=subsetInfoMin, ID="ID", toRecodeVal="mci")
}

%% ~Make other sections like Warning with \section{Warning }{....} ~


% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
