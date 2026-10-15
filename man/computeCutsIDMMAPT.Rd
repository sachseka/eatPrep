\name{computeCutsIDMMAPT}
\alias{computeCutsIDMMAPT}
\title{Compute IDM Cut Scores Using MAPT-Style Logistic Regressions}
\description{
Fits one pooled binary logistic regression per performance-level boundary to
compare Item Descriptor Matching (IDM) cuts with \code{computeCutsIDM()}.
}
\usage{
computeCutsIDMMAPT(
  dat,
  boundaries = c(1.5, 2.5, 3.5, 4.5),
  est_col = "est",
  item_id_col = NULL,
  rater_cols = NULL,
  rater_pattern = "Rater",
  rater_id_col = NULL,
  rating_col = NULL,
  input_format = c("auto", "long", "wide"),
  rating_levels = NULL,
  missing = c("drop", "error"),
  cut_labels = NULL,
  per_rater = TRUE
)
}
\arguments{
  \item{dat}{A data frame with item difficulty estimates and ratings.}
  \item{boundaries}{Increasing half-integers separating successive rating
  indices, for example \code{c(1.5, 2.5)} for three levels. If omitted and
  \code{rating_levels} is supplied, all adjacent boundaries are used.}
  \item{est_col}{Name of the numeric item difficulty column.}
  \item{item_id_col}{Name of the item identifier column. Required for long
  input; optional for wide input, where rows otherwise identify items.}
  \item{rater_cols}{Names of the rating columns in wide input. If \code{NULL},
  they are selected using \code{rater_pattern}.}
  \item{rater_pattern}{Regular expression used to select wide rating columns
  when \code{rater_cols} is \code{NULL}.}
  \item{rater_id_col}{Name of the rater identifier column in long input.}
  \item{rating_col}{Name of the rating column in long input.}
  \item{input_format}{Input layout. Long input requires \code{item_id_col},
  \code{rater_id_col}, and \code{rating_col}. Wide input has one row per item
  and one column per rater. \code{"auto"} infers the layout from the supplied
  column arguments.}
  \item{rating_levels}{Optional ordered vector of rating labels, mapped to
  indices \code{1, ..., K}. For example, \code{c("1a", "1b", "2", "3", "4")}.
  Without this argument, ratings must represent positive integer indices.}
  \item{missing}{Whether to drop missing rating observations or stop with an
  error. Item difficulties must always be numeric and finite, and identifiers
  must always be nonmissing.}
  \item{cut_labels}{Optional distinct, nonempty names for the requested cuts.
  Defaults to names such as \code{cut12} without explicit \code{rating_levels},
  or \code{cut_1a_1b} with explicit category labels.}
  \item{per_rater}{Logical scalar. Also fit separate regressions for each
  rater and return their cuts and diagnostics? These are auxiliary results
  and do not determine the pooled cuts.}
}
\details{
Following the logistic calculation in the MAPT Technical Manual (2006,
pp. 54--55), each boundary defines a binary outcome: the rating index exceeds
the boundary. All observed ratings enter a pooled binomial-logit regression
on item difficulty with equal weight. The cut is the difficulty at probability
0.5, calculated as minus the intercept divided by the slope. This probability
concerns the assigned performance level, not a correct item response.

The function implements this regression step, without the report's two-pass
rating trimming, so that methods can be compared on unchanged ratings.
It fits separate binary models, not a proportional-odds model, and its pooled
cut is not the average of separate rater cuts.

No moving average or isotonic regression is applied. Equal difficulties for
different items are allowed and do not require an arbitrary ordering.
Each item must have a consistent difficulty; repeated item--rater observations
are not allowed.

Unidentifiable, separated, non-converged, or non-positive-slope fits produce
\code{NA} cuts and diagnostics. Cuts outside the observed difficulty range
are retained and flagged as extrapolations. Independently fitted boundaries
can yield unordered cuts; these are flagged and are not rearranged.
Warnings summarize problematic fits. Inspect \code{cut_diagnostics} before
interpreting or comparing cuts.

For numerical stability, model objects use the standardized predictor
\code{difficulty = (est - est_center) / est_scale}. Each model stores its
\code{est_center} and \code{est_scale}. Diagnostics report intercepts, slopes,
and cuts on the original difficulty scale.

The model objects allow inspection of fitted curves, but their ordinary
independent-observation standard errors do not account for shared items or
raters, or for estimated item difficulties. No cut confidence intervals are
provided. \code{plotCutsIDM()} does not accept this function's output.
}
\value{
A list with the following components:
\item{cuts_summary}{One-row tibble of pooled cuts, with one column per cut.}
\item{cuts_per_person}{Auxiliary rater-specific cuts, or \code{NULL} when
\code{per_rater = FALSE}.}
\item{cuts_summary_per_person}{Arithmetic means of the finite rater-specific
cuts, distinct from the pooled result. Unavailable cuts are excluded; a mean
is \code{NA} if no finite individual cut is available. \code{NULL} when
\code{per_rater = FALSE}.}
\item{cut_diagnostics}{Pooled diagnostics with columns \code{cut_name},
\code{boundary}, \code{cut}, \code{status}, \code{n}, \code{n_lower},
\code{n_upper}, \code{intercept}, \code{slope}, \code{est_center},
\code{est_scale}, \code{min_est}, \code{max_est}, \code{extrapolated},
\code{converged}, and \code{warning}.}
\item{diagnostics_per_person}{Diagnostics for each rater, or \code{NULL}
when \code{per_rater = FALSE}.}
\item{models}{Named list of pooled \code{glm} fits; entries may be \code{NULL}
when a model cannot be fitted.}
\item{data_used}{Long-format data used in the models, with columns
\code{item_id}, \code{person}, \code{est}, \code{stage_raw}, and
\code{stage_label}.}
\item{n_dropped}{Number of missing rating observations removed. For wide
input this counts missing rating cells; for long input it counts supplied
rows with missing ratings.}
\item{boundaries, rating_levels, cut_labels, input_format, est_col, method}{
Settings describing the calculation.}
\item{cuts_ordered}{Whether all pooled cuts are strictly increasing in
boundary order; \code{NA} if any pooled cut is unavailable.}
}
\references{
\emph{Massachusetts Adult Proficiency Tests (MAPT): Technical Manual} (2006),
pp. 54--55.
\url{https://bpb-us-e2.wpmucdn.com/websites.umass.edu/dist/5/40195/files/2021/03/MAPT_TechnicalManualv1.pdf}
}
\seealso{\code{\link{computeCutsIDM}}, \code{\link[stats]{glm}}}
\examples{
# Ratings overlap along the difficulty scale, avoiding perfect separation.
dat <- data.frame(
  item = paste0("I", 1:15),
  est = seq(300, 650, length.out = 15),
  Rater1 = c(1, 2, 1, 3, 2, 4, 3, 2, 5, 3, 4, 5, 4, 5, 4),
  Rater2 = c(2, 1, 3, 1, 2, 3, 4, 3, 4, 5, 3, 4, 5, 4, 5)
)
mapt <- computeCutsIDMMAPT(dat, item_id_col = "item")
mapt$cuts_summary
mapt$cut_diagnostics

old <- computeCutsIDM(dat)
data.frame(
  method = c("moving_average", "logistic"),
  rbind(old$cuts_summary, mapt$cuts_summary)
)

# For labelled ratings in long format:
\dontrun{
mapt <- computeCutsIDMMAPT(
  dat_long, item_id_col = "item_cat", est_col = "est",
  rater_id_col = "Name", rating_col = "Kategorie", input_format = "long",
  rating_levels = c("1a", "1b", "2", "3", "4"), missing = "drop"
)
}
}
