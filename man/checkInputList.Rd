\name{checkInputList}
\alias{checkInputList}

\title{Check InputList structure for internal consistency
}
\description{This function checks whether inputList has the required form.
}
\usage{
checkInputList(inputList, mistypes = c("mnr", "mbd", "mir", "mbi"))
}
\arguments{
  \item{inputList}{
A list. Following the required structure for \code{\link{inputList}}s in \code{eatPrep}.
%Nur vollständige Liste liefert TRUE (bei fehlenden Sheets / Cols)
}
  \item{mistypes}{
Character vector. It will be checked, whether the missing types in this vector are defined for all items.
}
}
\details{
The xlsx-file produced by 'ZKDaemon' is expected to have the following sheets: \dQuote{units}, \dQuote{subunits}, \dQuote{values}, \dQuote{unitrecoding}, \dQuote{sav-files}, \dQuote{params}, \dQuote{aggregate-missings}, \dQuote{itemproperties}, \dQuote{propertylabels}, \dQuote{booklets}, and \dQuote{blocks}. \code{readDaemonXlsx} will produce a warning if any sheets are missing or wrongly specified.
}
\value{
Logical. \code{TRUE} if everything is OK, \code{FALSE} otherwise. %Nur vollständige Liste liefert TRUE (bei fehlenden Sheets / Cols = FALSE)
}
\examples{
data(inputList)
checkInputList(inputList)
}
\author{
Karoline Sachse
Philipp Franikowski
}
