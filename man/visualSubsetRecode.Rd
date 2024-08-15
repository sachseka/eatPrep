\name{visualSubsetRecode}
\alias{visualSubsetRecode}
\title{Inspect data subsets visually and recode instantaneously}
\description{
This function allows manual inspection and manual recoding of subsets of the data.}
\usage{visualSubsetRecode(dat, subsetInfo, ID, toRecodeVal="mci", useGroups=NULL)}
\arguments{
  \item{dat}{A data frame}
  \item{subsetInfo}{A data frame. Colnames have to be: "datCols" and whatever is specified in ID and useGroups.}
  \item{ID}{A character vector of length 1 indicating the name of the case identifier variable in \code{dat}. Default is \code{ID}.}
  	\item{toRecodeVal}{Optional: A scalar indicating recode string. }
  	\item{useGroups}{Optional: A character string indicating the name of the group identifier column in subsetInfo. Used for group level subsetting. }
}
\details{
tbd.
}
\value{
  A list of two data.frames. First is modified input data. Second is documentation of choices in subsetInfo.
}



\author{Karoline Sachse}

\examples{
data(inputList)
data(inputDat)

prepDat <- automateDataPreparation (inputList = inputList, datList = inputDat,
                                    readSpss = FALSE, checkData = FALSE, mergeData = TRUE,
                                    recodeData = TRUE, aggregateData = TRUE,
                                    scoreData = TRUE, writeSpss = FALSE, verbose = TRUE)

subsetInfoMin <- data.frame(ID=c("person100", "person101", "person102", "person103", "person101",
                                 "person100", "person101", "person102", "person103", "person101",
                                 "person101"),
                            datCols=c("I01", "I02", "I03", "I01", "I02", "I03",
                                      "I04", NA, "I02", "I03", "I04"))

\dontrun{datVisRec <- visualSubsetRecode(dat=prepDat, subsetInfo=subsetInfoMin, ID="ID",
                                toRecodeVal="mci", useGroups=NULL)}

subsetInfoMax <- data.frame(ID=c("person100", "person101", "person102", "person103", "person101",
                              "person100", "person101", "person102", "person103", "person101",
                              "person101"),
                         IDgroup=c(1,1,1,1,1,2,2,2,2,2,2),
                         datCols=c("I01", "I02", "I03", "I01", "I02", "I03",
                                   "I04", NA, "I02", "I03", "I04"))

\dontrun{datVisRec2 <- visualSubsetRecode(dat=prepDat, subsetInfo=subsetInfoMax, ID="ID",
                                 toRecodeVal="mci", useGroups="IDgroup")}
}

%% ~Make other sections like Warning with \section{Warning }{....} ~


% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
