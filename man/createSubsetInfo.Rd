\name{createSubsetInfo}
\alias{createSubsetInfo}
\title{Generate Subset Information for \code{VisualSubsetRecode()} from Classical Test Session Reports (Testsitzungsprotokoll)}
\description{
The \code{createSubsetInfo()} function processes a classical test session report, known as a "Testsitzungsprotokoll," which documents group-wise anomalies during a test session. For instance, test proctors might record issues such as broken audio, or if an entire test block was skipped due to a fire alarm. This function translates the test session report into the format required by \code{VisualSubsetRecode()}, enabling the identification and necessity of recoding of sessions as "mci" (missing coding impossible).
}
\usage{createSubsetInfo(tsp, booklets = NULL, blocks = NULL)}
\arguments{
   \item{tsp}{A data frame representing the classical test session report. This should include a group identifier column, a column for each test block, and a column indicating whether individual test units are affected (in addition to blocks or without blocks.}
\item{booklets}{Information about the test booklets, similar to \code{inputList\$booklet} (refer to \code{data(inputList)} for details). This parameter is optional if the \code{tsp} data frame contains only values in the column indicating individual units and does not include block-specific information.}
  \item{blocks}{Information about the test blocks, similar to \code{inputList\$blocks} (refer to \code{data(inputList)} for details). This parameter is optional if the \code{tsp} data frame contains only values in the column indicating individual units and does not include block-specific columns.}

}
\value{
 The function returns a data frame formatted appropriately for use as the \code{subsetInfo} argument in \code{VisualSubsetRecode()}.
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

\dontrun{
datVisRec <- visualSubsetRecode(dat=prepDat, subsetInfo=subsetInfoMin, ID="ID",
                                toRecodeVal="mci", useGroups=NULL)
                                }

subsetInfoMax <- data.frame(ID=c("person100", "person101", "person102", "person103", "person101",
                              "person100", "person101", "person102", "person103", "person101",
                              "person101"),
                         IDgroup=c(1,1,1,1,1,2,2,2,2,2,2),
                         datCols=c("I01", "I02", "I03", "I01", "I02", "I03",
                                   "I04", NA, "I02", "I03", "I04"))

\dontrun{
datVisRec2 <- visualSubsetRecode(dat=prepDat, subsetInfo=subsetInfoMax, ID="ID",
                                 toRecodeVal="mci", useGroups="IDgroup")
                                 }
}

%% ~Make other sections like Warning with \section{Warning }{....} ~


% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ ~kwd1 }
%\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
