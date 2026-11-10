\name{computeCutsIDMMAPT}
\alias{computeCutsIDMMAPT}
\title{Compute IDM Cut Scores Using MAPT-Style Logistic Regressions}
\description{
Finds cut scores from item difficulties and raters' assignments of items to
ordered performance levels. A cut score is a position on the item-difficulty
scale, such as 500. For each boundary between levels, the function fits a
logistic curve to all available ratings together. The cut is where that curve
reaches probability 0.5. This provides a MAPT-style comparison with the
moving-average method in \code{\link{computeCutsIDM}}.
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
  \item{boundaries}{Boundaries on the rating-index scale, in increasing order.
  Use half-integers, for example \code{c(1.5, 2.5)} for three levels. These
  numbers select which levels to separate; they are not item difficulties or
  the resulting cut scores. If omitted and \code{rating_levels} is supplied,
  all adjacent boundaries are used. See the label example below.}
  \item{est_col}{Name of the numeric item-difficulty column. The returned
  cut scores use this same scale. All values must be finite and nonmissing.}
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
  \item{rating_levels}{Optional vector of rating labels, listed from lowest
  to highest level. For example, \code{c("1a", "1b", "2", "3", "4")}.
  Their positions in this vector become indices \code{1, ..., K}, where
  \code{K} is the number of levels. The supplied order determines the order
  used in the calculation. Without this argument, ratings must be numeric
  positive integer indices.}
  \item{missing}{\code{"drop"} (default) removes missing ratings and keeps
  the other ratings, including other raters' ratings of the same item.
  \code{"error"} stops if a rating is missing. This option does not remove
  missing item difficulties or identifiers: these always cause an error.}
  \item{cut_labels}{Optional distinct, nonempty names for the requested cuts.
  Defaults to names such as \code{cut12} without explicit \code{rating_levels},
  or \code{cut_1a_1b} with explicit category labels. The name \code{"person"}
  is reserved and cannot be used for a cut.}
  \item{per_rater}{\code{TRUE} (default) also computes separate models and
  cuts for each rater, to help compare raters. \code{FALSE} computes only the
  joint result. Either choice gives the same pooled cuts.}
}
\details{
\subsection{1. Start with ordered ratings and item difficulties}{
Each observation is one rater's rating of one item. In long format, each
observation has its own row. In wide format, each item has one row and each
rater has a rating column. Each item must have the same difficulty wherever
it occurs. An item--rater pair must occur at most once.

The function uses the order of the rating levels. With
\code{rating_levels = c("1a", "1b", "2", "3", "4")}, the mapping is:
\tabular{ll}{
  Rating label \tab Index used in the calculation \cr
  \code{1a} \tab 1 \cr
  \code{1b} \tab 2 \cr
  \code{2} \tab 3 \cr
  \code{3} \tab 4 \cr
  \code{4} \tab 5
}
For example, \code{boundaries = 3.5} separates indices 3 and 4, so it
separates the labels \code{"2"} and \code{"3"}. The resulting cut might
be 500 on the item-difficulty scale. The boundary 3.5 and the cut 500 are
different quantities.
}

\subsection{2. Ask one yes-or-no question per boundary}{
For each boundary, ask: is this rating above the boundary? Code yes as 1
and no as 0. Let \eqn{i} identify an item, \eqn{r} a rater, and \eqn{k}
a requested boundary. Write \eqn{R_{ir}} for the rating index and
\eqn{b_k} for the boundary. The binary outcome is
\deqn{Y_{irk} = \mathbf{1}(R_{ir} > b_k).}{Y_irk = 1 if R_ir > b_k, and 0 otherwise.}
The symbol \eqn{\mathbf{1}(\cdot)}{1(condition)} means 1 when the condition
is true and 0 otherwise. For the boundary between labels \code{"2"} and
\code{"3"}, ratings \code{"1a"}, \code{"1b"}, and \code{"2"} give 0;
ratings \code{"3"} and \code{"4"} give 1.

A separate logistic curve is fitted for each boundary. It describes how the
probability of a rating on the upper side changes with item difficulty:
\deqn{p_k(x) = \frac{1}{1 + \exp[-(\alpha_k + \beta_k x)]}.}{p_k(x) = 1 / (1 + exp(-(alpha_k + beta_k * x))).}
Here, \eqn{x} is item difficulty, \eqn{p_k(x)} is the fitted probability,
\eqn{\alpha_k}{alpha_k} is the intercept, and \eqn{\beta_k}{beta_k} is the
slope. The intercept and slope together determine the curve's position and
steepness. The function \eqn{\exp}{exp} is the exponential function. A
positive slope means that higher item difficulty goes with a higher
probability of a rating above the boundary.

The equivalent logit equation, using the natural logarithm \eqn{\log}{log}, is
\deqn{\log\left(\frac{p_k(x)}{1-p_k(x)}\right) = \alpha_k + \beta_k x.}{log(p_k(x) / (1 - p_k(x))) = alpha_k + beta_k * x.}
The coefficients are estimated by maximum likelihood: the fitted curve is
chosen to best account for the observed zeros and ones under this model.
This is a probability of a \strong{rating-level assignment}. It is not the
probability that a student answers the item correctly.
}

\subsection{3. Find where the curve reaches 0.5}{
The cut \eqn{c_k} is the difficulty where the fitted probability is 0.5.
At that point, the model gives equal probabilities to ratings on the two
sides of the boundary. Since the logit of 0.5 is zero,
\deqn{p_k(c_k)=0.5 \quad\Longrightarrow\quad
  \alpha_k + \beta_k c_k = 0 \quad\Longrightarrow\quad
  c_k = -\frac{\alpha_k}{\beta_k}.}{p_k(c_k) = 0.5 implies alpha_k + beta_k * c_k = 0, so c_k = -alpha_k / beta_k.}
For example, an intercept of -10 and a slope of 0.02 give
\deqn{c = -\frac{-10}{0.02} = 500.}{c = -(-10) / 0.02 = 500.}
At difficulty 500, the fitted probability is 0.5. There need not be an item
with exactly that difficulty, nor exactly half of the observed ratings on
each side at that point. The cut comes from the fitted curve.
}

\subsection{4. Keep pooled cuts and means of rater cuts separate}{
\strong{The main result is \code{cuts_summary}.} It contains the cuts from
models fitted to all available item--rater observations together. This is
called pooling. Each observed rating has equal weight. A rater with more
observed ratings therefore contributes more observations; raters are not
first reduced to equally weighted summaries. There are no rater-specific
intercepts or slopes in the pooled model.

With \code{per_rater = TRUE}, the function also repeats the calculation for
each rater separately. These cuts are in \code{cuts_per_person}. A third
table, \code{cuts_summary_per_person}, contains their arithmetic means:
\deqn{\bar c_k = \frac{1}{m_k}\sum_{r\in V_k} c_{rk}.}{mean_cut_k = sum of the available rater cuts for boundary k / m_k.}
Here, \eqn{c_{rk}} is rater \eqn{r}'s cut for boundary \eqn{k}, \eqn{V_k}
is the set of raters with a finite cut for that boundary, and \eqn{m_k}
is their number. If none is available, the mean is \code{NA}.

For example, rater cuts of 480 and 520 have mean 500. The pooled model must
still be fitted to the ratings; its cut need not be 500. Fitting a joint
curve and averaging separately estimated cuts are different calculations.
The mean table is provided for comparison and does not determine
\code{cuts_summary}.

Use \code{plotCutsIDM(result, show_aggregate = TRUE)} to show individual
raters and the joint model. The \code{Pooled (MAPT)} panel uses
\code{cuts_summary}. With \code{per_rater = FALSE}, the plot shows only
that pooled panel, even when \code{show_aggregate = FALSE}.
}

\subsection{5. Read the diagnostics before interpreting a cut}{
Start with \code{cut_diagnostics}. Its \code{status} column explains whether
a usable cut was obtained. \code{NA} means that no usable cut is available;
it does not mean a cut of zero. The corresponding rater information is in
\code{diagnostics_per_person}.
\describe{
  \item{\code{ok}}{A finite cut from a converged, increasing curve is available.
  Also check \code{extrapolated} and \code{warning}.}
  \item{\code{no_data}}{No observed ratings remain for this rater.}
  \item{\code{one_class}}{All available ratings are on the same side of this boundary.}
  \item{\code{constant_est}}{All available item difficulties are identical.}
  \item{\code{separation}}{The difficulty ranges of the zero and one outcomes
  do not overlap, or only meet at an endpoint. Ordinary logistic regression
  then has no finite maximum-likelihood slope for this boundary.}
  \item{\code{nonpositive_slope}}{The fitted curve decreases or is numerically
  too flat to supply an acceptable increasing-curve cut.}
  \item{\code{fit_error}, \code{non_convergence}, \code{non_finite}}{The fit
  failed, did not converge to an acceptable solution, or produced non-finite
  numerical results. Read the \code{warning} column for any further details.}
}
All statuses other than \code{ok} give an \code{NA} cut. Some diagnostics
can also be \code{NA} when fitting stopped early.

\strong{Extrapolation:} a finite cut outside the observed difficulty range
is retained, with \code{extrapolated = TRUE}. For example, a cut of 700 with
items only between 300 and 650 extends beyond the observed items. Treat it
more cautiously than a cut within that range.

\strong{Order:} each boundary has its own model, so the resulting cuts can
cross or coincide. \code{cuts_ordered} is \code{TRUE} only when all pooled
cuts are strictly increasing in boundary order. It is \code{FALSE} when
all are available but not strictly increasing, and \code{NA} when any is
unavailable. The function does not rearrange cuts to hide this problem.
}

\subsection{6. What the calculation does and does not guarantee}{
This implements the logistic calculation in the MAPT Technical Manual
(2006, pp. 54--55). It omits the report's two-pass removal of unusual
ratings, so that methods can be compared using unchanged ratings. Each
boundary has its own intercept and slope; this is not a proportional-odds
model, which would share a slope across boundaries.

No moving average or isotonic regression is applied. Different items may
have equal difficulties; there is no need to put tied items in an arbitrary
order. This removes that source of order dependence, but it does not make
every cut stable. Changed difficulties or ratings can still change a cut;
in particular, a shallow curve makes its 0.5 crossing sensitive to changes.

No confidence intervals for cuts are provided. Ordinary standard errors
in the stored \code{glm} objects do not account for dependence between
ratings of the same item or ratings by the same rater. They also do not
account for uncertainty in the estimated item difficulties.
}

\subsection{Technical note: the scale in stored model objects}{
For numerical stability, the predictor inside each stored model is
\deqn{z = \frac{x-\mu}{s},}{z = (x - mu) / s,}
where \eqn{\mu}{mu} is the mean difficulty and \eqn{s} is its sample standard
deviation over that model's observed rating rows. The model stores these as
\code{est_center} and \code{est_scale}; its predictor column is called
\code{difficulty}. Thus, predicting from a stored model requires standardized
values, not raw \code{est} values. The reported diagnostic \code{intercept},
\code{slope}, and all cut tables are already on the original difficulty
scale used in the formulas above. You can use these tables directly.
}
}
\value{
A list of class \code{cutsIDMMAPT} with the following components:
\item{cuts_summary}{The main result: a one-row table (tibble) of pooled cuts,
with one column per boundary, on the original item-difficulty scale.}
\item{cuts_per_person}{Auxiliary rater-specific cuts, or \code{NULL} when
\code{per_rater = FALSE}.}
\item{cuts_summary_per_person}{Arithmetic means of the finite rater-specific
cuts, distinct from the pooled result. Unavailable cuts are excluded; a mean
is \code{NA} if no finite individual cut is available. \code{NULL} when
\code{per_rater = FALSE}.}
\item{cut_diagnostics}{One row per pooled boundary. \code{cut_name},
\code{boundary}, and \code{cut} identify the requested boundary and resulting
cut. \code{n} counts rating observations, not unique items; \code{n_lower}
and \code{n_upper} count the zero and one outcomes. \code{intercept} and
\code{slope} are the coefficients on the original difficulty scale.
\code{min_est} and \code{max_est} give the observed range.
\code{status}, \code{extrapolated}, \code{converged}, and \code{warning}
describe fit quality and problems. \code{est_center} and \code{est_scale}
record the numerical standardization described above.}
\item{diagnostics_per_person}{Diagnostics for each rater, or \code{NULL}
when \code{per_rater = FALSE}.}
\item{models}{Named list of pooled \code{glm} fits; entries may be \code{NULL}
when a model cannot be fitted.}
\item{models_per_person}{Named list of raters, each containing a list of
\code{glm} fits named by cut. Entries may be \code{NULL} when a model cannot
be fitted. The whole component is \code{NULL} when \code{per_rater = FALSE}.}
\item{data_used}{Long-format data used in the models, with columns
\code{item_id}, \code{person}, \code{est}, \code{stage_raw}, and
\code{stage_label}.}
\item{n_dropped}{Number of missing rating observations removed. For wide
input this counts missing rating cells; for long input it counts supplied
rows with missing ratings.}
\item{boundaries, rating_levels, cut_labels, input_format, est_col,
item_id_col, rater_id_col, rating_col, missing, method}{Settings describing
the calculation, input columns, and missing-rating policy.}
\item{cuts_ordered}{Whether all pooled cuts are strictly increasing in
boundary order; \code{NA} if any pooled cut is unavailable.}
}
\references{
\emph{Massachusetts Adult Proficiency Tests (MAPT): Technical Manual} (2006),
pp. 54--55.
\url{https://bpb-us-e2.wpmucdn.com/websites.umass.edu/dist/5/40195/files/2021/03/MAPT_TechnicalManualv1.pdf}
}
\seealso{\code{\link{computeCutsIDM}}, \code{\link{plotCutsIDM}},
\code{\link{summary.cutsIDMMAPT}},
\code{\link[stats]{glm}}}
\examples{
# Ratings overlap along the difficulty scale, avoiding perfect separation.
dat <- data.frame(
  item = paste0("I", 1:15),
  est = seq(300, 650, length.out = 15),
  Rater1 = c(1, 2, 1, 3, 2, 4, 3, 2, 5, 3, 4, 5, 4, 5, 4),
  Rater2 = c(2, 1, 3, 1, 2, 3, 4, 3, 4, 5, 3, 4, 5, 4, 5)
)
mapt <- computeCutsIDMMAPT(dat, item_id_col = "item")
print(mapt)
summary(mapt, per_rater = TRUE)
# Main result: use the ratings from both raters together.
mapt$cuts_summary
mapt$cut_diagnostics[c("cut_name", "cut", "status", "extrapolated")]

# Two different comparison results: individual cuts and their means.
mapt$cuts_per_person
mapt$cuts_summary_per_person
plotCutsIDM(mapt, show_aggregate = TRUE)

# A hand calculation for an illustrative curve, not the fitted data above:
alpha <- -10
beta <- 0.02
cut <- -alpha / beta                   # 500
1 / (1 + exp(-(alpha + beta * cut)))  # 0.5

# Compare the same ratings using the moving-average method.
old <- computeCutsIDM(dat)
data.frame(
  method = c("moving_average", "logistic"),
  rbind(old$cuts_summary, mapt$cuts_summary)
)

# A complete long-format example with labels 1a, 1b, 2, 3, 4.
level_labels <- c("1a", "1b", "2", "3", "4")
dat_long <- tidyr::pivot_longer(
  dat, cols = c("Rater1", "Rater2"),
  names_to = "Name", values_to = "Kategorie"
)
dat_long$Kategorie <- level_labels[dat_long$Kategorie]
labelled <- computeCutsIDMMAPT(
  dat_long, item_id_col = "item", est_col = "est",
  rater_id_col = "Name", rating_col = "Kategorie", input_format = "long",
  rating_levels = level_labels, missing = "drop"
)
labelled$cuts_summary
plotCutsIDM(labelled, show_aggregate = TRUE)

# Just the boundary between labels "2" and "3" (indices 3 and 4).
one_boundary <- computeCutsIDMMAPT(
  dat_long, item_id_col = "item", rater_id_col = "Name",
  rating_col = "Kategorie", input_format = "long",
  rating_levels = level_labels, boundaries = 3.5, per_rater = FALSE
)
one_boundary$cuts_summary
}
