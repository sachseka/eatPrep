\name{visualSubsetRecode}
\alias{visualSubsetRecode}
\title{Visually Inspect and Recode Data Subsets Interactively}
\description{
\code{visualSubsetRecode} allows users to manually inspect and recode specific data subsets in an interactive manner. This function is particularly useful when you need to review subsets of data flagged for potential issues, such as a group of students in a large assessment where audio issues were reported. After visually inspecting the flagged responses, you can decide whether to recode the entire subset to a specified value, such as "missing coding impossible" (mci), which is typically treated as \code{NA} during subsequent IRT scaling.

This function guides you through the flagged subsets sequentially, enabling you to make immediate, interactive decisions about how to handle each subset.

The following options are available during the recoding process (as an answer to the question "Do you want to recode this subset to 'mci'?"):

\enumerate{
\item yes -- Recode the subset to \code{toRecodeVal} (e.g., 'mci'). All values in \code{dat} corresponding to the subset will be replaced with the chosen recode value.
\item no -- Do not recode. No changes will be made to the data.
\item flag, maybe later -- Flag for later review. No changes will be made, but the subset will be marked in the returned \code{modifiedSubsetInfo} data frame for future attention.
\item go back -- Return to the previous subset for further review.
\item reset to original values -- if the subset was previously recoded and you wish to undo the changes, this option restores the original values. }

}
\usage{visualSubsetRecode(dat, subsetInfo, ID, toRecodeVal="mci", useGroups=NULL)}
\arguments{
  \item{dat}{A data frame containing individuals and variables in a wide format. See \code{prepDat} in examples for an example.}
  \item{subsetInfo}{A data frame where the column names must include the following: [ID]: Specifies the ID name in the first data set and identifies individual persons who are flagged. datCols: Indicates the variable(s) on which the person identified by the ID has been flagged. useGroups (optional): Identifies groups of persons that should be displayed together during the review process. See \code{subsetInfoMax} in examples for an example.}
  \item{ID}{A character vector of length 1 indicating the name of the case identifier variable in \code{dat}. Default is \code{"ID"}.}
  	\item{toRecodeVal}{Optional: A scalar indicating recode string. }
  	\item{useGroups}{Optional: A character string indicating the name of the group identifier column in subsetInfo. Used for group level subsetting. }
}
\value{
  The function returns a list containing two data frames named "modifiedDat" and "modifiedSubsetInfo". The first data frame is the modified input data, identical to the original except for the changes made during the review process. The second data frame, stored in subsetInfo, documents the choices made during the recoding process.
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
