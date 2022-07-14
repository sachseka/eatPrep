\name{meanKappa}
\alias{meanKappa}
\title{Cohens kappa and Brennan/Predigers kappa among several raters}
\description{This is a wrapper for the \code{\link[irr]{kappa2}} or the
\code{\link[ragree]{bp.coeff.raw}} function. Computes Cohens kappa among several
raters (at least 2) for one item and several persons.}
\usage{
meanKappa( dat , type = c("Cohen", "BrennanPrediger"), weight = "unweighted" ,
           weight.mean = TRUE )
}
\arguments{
  \item{dat}{
Data frame with at least two columns, with examinees in the rows and raters in the columns.
}
  \item{type}{
Which type of kappa should be computed? If \code{"Cohen"}, \code{\link[irr]{kappa2}}
is called, if \code{"BrennanPrediger"}, \code{\link[ragree]{bp.coeff.raw}} is called.
}
  \item{weight}{
either a character string specifying one predefined set of weights or a numeric
vector with own weights. If \code{type = "Cohen"}, \code{weight} can be
\code{"unweighted"}, \code{"equal"}, or \code{"squared"}. If \code{type = "BrennanPrediger"},
\code{weight} can be \code{"quadratic"}, \code{"linear"}, \code{"ordinal"},
\code{"radical"}, \code{"ratio"}, \code{"circular"}, \code{"bipolar"},
or \code{"unweighted"}.
}
  \item{weight.mean}{
Logical: TRUE, if agreement is weighted by number of rater subjects. FALSE, if it is
averaged among all rater pairs.
}
}
\value{
A list. First element is a data frame with kappa values between raters pairs.
Second element is a scalar with mean kappa among all raters.
}
\references{
Brennan, R.L., and Prediger, D. J. (1981). ``Coefficient Kappa: some uses,
misuses, and alternatives." Educational and Psychological Measurement, 41,
687-699.\cr\cr
Cohen, J. (1960). A coefficient of agreement for nominal scales. Educational
and Psychological Measurement, 20, 37-46.\cr\cr
Cohen, J. (1968). Weighted kappa: Nominal scale agreement with provision for scaled
disagreement or partial credit. Psychological Bulletin, 70, 213-220.\cr\cr
Fleiss, J.L., Cohen, J., & Everitt, B.S. (1969). Large sample standard errors of
kappa and weighted kappa. Psychological Bulletin, 72, 323-327.

}
\examples{
data(rater)
v01 <- subset(rater, variable == "V01")
dat <- reshape2::dcast( v01, id~rater, value.var = "value")
kap <- meanKappa(dat[,-1])
}
