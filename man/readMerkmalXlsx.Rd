\name{readMerkmalXlsx}
\alias{readMerkmalXlsx}

\title{Read xlsx-Files Produced by IQB Item-DB named "Merkmalsauszug"
}
\description{This function is primarily intended for internal use at the Institute for Educational Quality Improvement (IQB). The xlsx-files for this function are produced by the software IQB Item-DB using information stored in the IQB-Databases.
}
\usage{
readMerkmalXlsx(filename, tolcl = FALSE, alleM = TRUE)
}
\arguments{
  \item{filename}{
A character string containing path, name and extension of .xlsx produced by IQB Item-DB via 'Merkmalsauszug'.
}
  \item{tolcl}{
Logical. Indicating whether the Item-ID should be created converting numbers to lowercase letters (as required in the English project). Default is \code{FALSE}.
}
  \item{alleM}{
Logical. Indicating whether a merged data frame containing Itemmerkmale and Aufgabenmerkmale together will be created. Default is \code{TRUE}.
}
}
\details{
The xlsx-file produced by 'IQB Item-DB' is expected to have the following sheets: \dQuote{Itemmerkmale}, \dQuote{Aufgabenmerkmale}. Order doesn't matter. \code{readMerkmalXlsx} will produce a warning if any sheets are missing or wrongly specified.
}
\value{
A list of data frames containing Itemmerkmale, Aufgabenmerkmale and AlleMerkmale (optional).
}
\examples{
readMerkmalXlsx(system.file("extdata", "itemmerkmale.xlsx", package = "eatPrep"))
}

