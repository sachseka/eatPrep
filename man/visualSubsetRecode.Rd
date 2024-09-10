\name{visualSubsetRecode}
\alias{visualSubsetRecode}
\title{Inspect data subsets visually and recode instantaneously}
\description{
This function facilitates the manual inspection and recoding of data subsets. For example, if a class of students in a large assessment is flagged with an issue such as 'audio was broken,' you may want to verify the validity of their response patterns. If their responses seem invalid, you can choose to recode the entire class to a value like 'missing coding impossible' (mci), which is typically treated as NA during IRT scaling later on. The function allows you to visually review all flagged subsets sequentially and make interactive decisions on whether to recode their data.}
\usage{visualSubsetRecode(dat, subsetInfo, ID, toRecodeVal="mci", useGroups=NULL)}
\arguments{
  \item{dat}{A data frame containing individuals and variables in a wide format. See \code{prepDat} in examples for an example.}
  \item{subsetInfo}{A data frame where the column names must include the following: [ID]: Specifies the ID name in the first data set and identifies individual persons who are flagged. datCols: Indicates the variable(s) on which the person identified by the ID has been flagged. useGroups (optional): Identifies groups of persons that should be displayed together during the review process. See \code{subsetInfoMax} in examples for an example.}
  \item{ID}{A character vector of length 1 indicating the name of the case identifier variable in \code{dat}. Default is \code{"ID"}.}
  	\item{toRecodeVal}{Optional: A scalar indicating recode string. }
  	\item{useGroups}{Optional: A character string indicating the name of the group identifier column in subsetInfo. Used for group level subsetting. }
}
\value{
  The function returns a list containing two data frames. The first data frame is the modified input data, identical to the original except for the changes made during the review process. The second data frame, stored in subsetInfo, documents the choices made during the recoding process.
}



\author{Karoline Sachse}

\examples{
data(inputList)
data(inputDat)

prepDat <- automateDataPreparation (inputList = inputList, datList = inputDat,
                                    readSpss = FALSE, checkData = FALSE, mergeData = TRUE,
                                    recodeData = TRUE, aggregateData = TRUE,
                                    scoreData = TRUE, writeSpss = FALSE, verbose = FALSE)

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
