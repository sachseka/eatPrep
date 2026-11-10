\name{summary.cutsIDMMAPT}
\alias{summary.cutsIDMMAPT}
\alias{print.cutsIDMMAPT}
\alias{print.summary.cutsIDMMAPT}
\title{Inspect MAPT Cuts and Fit Diagnostics}
\description{
Show the main MAPT result without printing all fitted models and input rows.
The main cuts use the ratings from all raters together. They are not averages
of separately estimated rater cuts.
}
\usage{
\method{summary}{cutsIDMMAPT}(object, per_rater = FALSE, ...)

\method{print}{cutsIDMMAPT}(x, digits = 3, ...)

\method{print}{summary.cutsIDMMAPT}(x, digits = 3, ...)
}
\arguments{
\item{object}{A result from \code{\link{computeCutsIDMMAPT}}.}
\item{x}{A MAPT result or its summary, as appropriate.}
\item{per_rater}{Also include individual rater cuts and their complete
diagnostic tables in the summary? Defaults to \code{FALSE}. This does not
fit new models: individual results must have been computed with
\code{computeCutsIDMMAPT(..., per_rater = TRUE)}.}
\item{digits}{Number of decimal places shown in numeric table columns,
from 0 to 15. Stored values retain their full precision.}
\item{...}{Additional arguments. The result's print method forwards these
to the summary print method; otherwise they are currently unused.}
}
\details{
Typing the result's name or calling \code{print(result)} displays pooled
cuts, their status, and whether they fall outside the observed difficulty
range. It also reports missing ratings removed during preparation.

A status of \code{"ok"} means a usable cut was obtained. A different
status means that the cut is unavailable; see
\code{\link{computeCutsIDMMAPT}} for the individual failure reasons.
\code{extrapolated = TRUE} means that the fitted curve reaches probability
0.5 outside the observed item difficulty range. Such a cut is still
returned, but is supported by extrapolation of the model.

The \code{issues} table contains every pooled or available individual fit
with an unusable cut, an extrapolated cut, or a recorded numerical warning.
The printed view shows at most the first 20 flagged fits; the table itself
is complete. Pooled rows have \code{scope = "pooled"} and a missing
\code{person}; individual rows have \code{scope = "rater"} and the rater ID.
The display also flags pooled cuts that are not strictly increasing, or
explains why their order cannot be checked.

Use \code{summary(result, per_rater = TRUE)} to compare individual rater
cuts. These are auxiliary results and do not replace the pooled estimate.
Models and input ratings remain available in the original result through
\code{result$models}, \code{result$models_per_person}, and
\code{result$data_used}. Summarising does not refit or modify the result.
}
\value{
\code{summary()} returns an object of class \code{summary.cutsIDMMAPT}:
\describe{
\item{cuts_summary, cut_diagnostics}{The original pooled cut table and
complete pooled diagnostics.}
\item{issues}{All flagged fits, with columns \code{scope}, \code{person},
\code{cut_name}, \code{status}, \code{extrapolated}, and \code{warning}.}
\item{n_ratings, n_items, n_raters}{Counts of retained rating observations,
distinct items, and distinct raters in \code{data_used}. Raters with only
missing ratings are excluded from these counts, but can appear with
\code{no_data} individual-fit diagnostics.}
\item{n_dropped}{Number of missing ratings removed.}
\item{cuts_ordered}{Whether all pooled cuts are strictly increasing in
boundary order; \code{NA} if a pooled cut is unavailable.}
\item{per_rater_available, per_rater}{Whether individual results were
computed and whether they were requested in this summary.}
\item{cuts_per_person, diagnostics_per_person}{Individual results when
requested and available, otherwise \code{NULL}.}
\item{method}{The method description from the original result.}
}
Both print methods return their input invisibly.
}
\seealso{\code{\link{computeCutsIDMMAPT}}, \code{\link{plotCutsIDM}}}
\examples{
dat <- data.frame(
  est = 1:12,
  RaterA = c(1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2),
  RaterB = c(1, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2)
)
cuts <- computeCutsIDMMAPT(dat, boundaries = 1.5)
cuts
s <- summary(cuts, per_rater = TRUE)
s
s$cuts_summary
s$issues
s$diagnostics_per_person
# Fitted models and the actual ratings stay in the original object.
stats::coef(cuts$models[[1]])
head(cuts$data_used)
}
