\name{summary.cutsIDMOrdinal}
\alias{summary.cutsIDMOrdinal}
\alias{print.cutsIDMOrdinal}
\alias{print.summary.cutsIDMOrdinal}
\title{Inspect Ordinal IDM Cuts and Model Diagnostics}
\description{
Summarizes reference cuts, random-effect variation, and fit diagnostics
without printing the full ordinal model or the rating data.
}
\usage{
\method{summary}{cutsIDMOrdinal}(object, per_rater = FALSE, ...)

\method{print}{cutsIDMOrdinal}(x, digits = 3, ...)

\method{print}{summary.cutsIDMOrdinal}(x, digits = 3, ...)
}
\arguments{
\item{object}{A result from \code{\link{computeCutsIDMOrdinal}}.}
\item{x}{An ordinal IDM result or its summary, as appropriate.}
\item{per_rater}{Include conditional rater cuts and their diagnostics?
Defaults to \code{FALSE}. Individual results must have been requested
when calling \code{computeCutsIDMOrdinal(..., per_rater = TRUE)}.
No model is refitted.}
\item{digits}{Number of decimal places displayed in numeric tables,
from 0 to 15. Stored values retain their full precision.}
\item{...}{Additional arguments passed to the summary print method
when printing a result; otherwise currently unused.}
}
\details{
The main cuts in \code{cuts_summary} set both random intercepts to zero.
Conditional rater cuts use each observed rater's estimated random
intercept and set the item effect to zero. They come from the same joint
model and are not independently fitted rater cuts. The main result is not
their mean.

Check the model diagnostics even when all cuts are available. In
particular, model convergence does not establish the proportional-odds
assumption, and a random-effect variance close to zero requires a
different interpretation from a failed fit. Extrapolated cuts are
retained but lie outside the corresponding observed difficulty range.
Unavailable cuts are recorded as \code{NA}, not zero.

The original object retains \code{model}, \code{data_used},
\code{rater_effects}, and \code{item_effects} for more detailed inspection.
Summarizing does not change those objects.
}
\value{
\code{summary()} returns an object of class
\code{summary.cutsIDMOrdinal} containing the reference cut table,
cut and model diagnostics, variance components, counts of retained
ratings/items/raters and dropped ratings, cut-order information, and
optional conditional rater results. Both print methods return their
input invisibly.
}
\seealso{\code{\link{computeCutsIDMOrdinal}}, \code{\link{plotCutsIDM}}}
\examples{
dat <- data.frame(
  est = 1:12,
  RaterA = c(1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2),
  RaterB = c(1, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2)
)
cuts <- computeCutsIDMOrdinal(dat, rating_levels = c(1, 2),
                              random_effects = character())
cuts
summary(cuts, per_rater = TRUE)
cuts$model_diagnostics
}
