\name{summary.cutsIDM}
\alias{summary.cutsIDM}
\alias{print.summary.cutsIDM}
\title{Summarize IDM Cut Score Objects}
\description{
Builds and prints a compact summary for objects returned by \code{\link{computeCutsIDM}}.
}
\usage{
\method{summary}{cutsIDM}(object, digits = NULL, ...)
\method{print}{summary.cutsIDM}(x, digits = NULL, ...)
}
\arguments{
  \item{object}{A \code{cutsIDM} object returned by \code{\link{computeCutsIDM}}.}
  \item{digits}{Optional integer. Number of digits used when printing numeric summary columns. The stored summary tables are not rounded.}
  \item{...}{Further arguments passed to \code{print()} for the individual tables.}
  \item{x}{A \code{summary.cutsIDM} object returned by \code{summary()}.}
}
\details{
The summary method does not recompute cut scores. It reorganizes the main results already stored in the \code{cutsIDM} object:
\itemize{
  \item \code{settings} reports the input format, missing-value handling, estimate and item identifier columns, number of raters, number of ordered item positions, and number of requested cuts.
  \item \code{boundaries} connects each cut label with the numeric boundary on the internal ordinal scale and, where possible, with the lower and upper rating levels it separates.
  \item \code{cuts_summary} contains the mean cut score on the item difficulty scale.
  \item \code{cut_statistics} contains mean, sample standard deviation, and standard error for interpolated item positions and difficulty-scale cuts.
  \item \code{level_statistics} describes the item-difficulty intervals implied by the mean cuts.
  \item \code{modal_values} contains item-wise modal raw rating stages and labels.
  \item \code{rater_modal_correlations} reports correlations between each rater's raw rating series and the item-wise modal values, with all-rater and leave-one-rater-out modal criteria.
  \item \code{kappa_summary} and \code{rater_kappa_statistics} summarize finite pairwise Cohen's kappa values overall and per rater.
  \item \code{fleiss_kappa} and \code{icc_statistics} provide multi-rater agreement diagnostics based on complete item rows.
}
The returned object is a regular list with class \code{summary.cutsIDM}, so all component tables can still be extracted programmatically.
}
\value{
A list of class \code{summary.cutsIDM} with the components \code{settings}, \code{boundaries}, \code{cuts_summary}, \code{cut_statistics}, \code{level_statistics}, \code{modal_values}, \code{rater_modal_correlations}, \code{kappa_summary}, \code{rater_kappa_statistics}, \code{fleiss_kappa}, and \code{icc_statistics}. Printing the object returns it invisibly.
}
\examples{
dat <- data.frame(
  est = seq(100, 500, by = 100),
  Rater1 = c(1, 1, 2, 3, 4),
  Rater2 = c(1, 2, 2, 3, 4)
)

cuts <- computeCutsIDM(dat, boundaries = c(1.5, 2.5))
summary(cuts)

sum_cuts <- summary(cuts)
sum_cuts$boundaries
sum_cuts$level_statistics
sum_cuts$rater_kappa_statistics
sum_cuts$icc_statistics
}
