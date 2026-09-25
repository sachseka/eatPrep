\name{computeCutsIDM}
\alias{computeCutsIDM}
\title{Compute Cut Scores based on Rater's Monotonized Moving Averages}
\description{
Calculates an arbitrary number of cut scores for Item Descriptor Matching (IDM). The number of cuts is determined by the length of the \code{boundaries} argument.
}
\usage{
computeCutsIDM(
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
  missing = c("drop", "smooth", "error"),
  cut_labels = NULL
)
}
\arguments{
  \item{dat}{A data frame containing item difficulty estimates and rater ratings. Long and wide input formats are supported.}
  \item{boundaries}{Finite, strictly increasing numeric vector. The cut boundaries on the internal rating scale. For example, \code{c(1.5, 2.5, 3.5)} calculates cuts between four adjacent performance levels.}
  \item{est_col}{Character scalar. Name of the column containing item difficulty estimates. Defaults to \code{"est"}.}
  \item{item_id_col}{Optional character scalar. Name of an item identifier column. In long-format input this is used to complete the full item-by-rater grid before smoothing; omitted item-rater combinations are treated as missing ratings. If \code{NULL}, \code{est_col} is used as the item identity in long-format input. Supply \code{item_id_col} when different items can share the same difficulty estimate.}
  \item{rater_cols}{Character vector. Names of the rater rating columns for wide-format input. If \code{NULL}, rater columns are selected with \code{rater_pattern}.}
  \item{rater_pattern}{Character scalar. Pattern used to find rater rating columns when \code{rater_cols = NULL} in wide-format input. Defaults to \code{"Rater"}.}
  \item{rater_id_col}{Character scalar. Name of the rater identifier column for long-format input. Rater identifiers may be names or IDs.}
  \item{rating_col}{Character scalar. Name of the rating column for long-format input. Values may be numeric or ordinal labels when \code{rating_levels} is supplied.}
  \item{input_format}{Character scalar. One of \code{"auto"}, \code{"long"}, or \code{"wide"}. In \code{"auto"} mode, the function uses long format when both \code{rater_id_col} and \code{rating_col} are supplied, and wide format when neither is supplied. Supplying only one of these arguments is an error.}
  \item{rating_levels}{Optional atomic vector defining the ordered rating scale, for example \code{c("1a", "1b", "2", "3", "4")}. Supplied levels, including numeric levels, are mapped to consecutive stages starting at 1. Non-numeric ratings require this argument. If \code{boundaries} is not supplied, adjacent boundaries are derived from these levels.}
  \item{missing}{Character scalar. \code{"drop"} removes missing ratings before smoothing each rater's remaining sequence; the corresponding rows stay missing in the smoothed and isotonic series. \code{"smooth"} retains the full sequence and averages available values in each three-point window, potentially producing a smoothed value at a missing rating. \code{"error"} rejects missing ratings, including omitted long-format item-rater combinations. See Details for short sequences and empty windows.}
  \item{cut_labels}{Optional character vector with one label per boundary. Labels must be unique and start with \code{"cut"} so that \code{plotCutsIDM()} remains compatible.}
}
\details{
The function supports two input formats. In long format, each row contains one item-rater combination and the columns identified by \code{est_col}, \code{rater_id_col}, and \code{rating_col}. In wide format, each row contains one item and one or more rater rating columns. Wide-format input keeps the previous default behavior.

Long-format input is completed internally to the full item-by-rater grid before smoothing. Thus an omitted item-rater row is interpreted like an explicit missing rating, not like a removed item. If \code{item_id_col} is supplied, it defines the item identity used for this completion. If it is not supplied, \code{est_col} is used as a fallback item identity; this requires at most one rating per rater and difficulty value. When multiple distinct items may have identical difficulty estimates, \code{item_id_col} should be supplied.

All input is normalized internally to a long representation with item difficulty, rater identifier, and numeric rating stage. Whenever \code{rating_levels} is supplied, its entries define the ordinal order and are mapped to \code{1, 2, ..., k} for computation, even if the entries are numeric. Without \code{rating_levels}, numeric ratings are used unchanged.

The smoothing padding and plot scale are based on the observed rating scale and the supplied boundaries. Missing ratings are handled according to \code{missing}. The default \code{"drop"} is conservative: missing ratings do not create smoothed values. The \code{"smooth"} option uses the legacy-like moving average behavior where missing values inside the smoothing window are ignored.

The function processes each rater by:
\enumerate{
  \item Sorting items by difficulty (\code{est_col}).
  \item Applying a symmetric three-point moving average (order = 1) with the padding values defined below, unless the sequence to be smoothed has fewer than three entries.
  \item Applying isotonic regression (\code{isoreg}) to ensure the mapping of difficulty to level is non-decreasing.
  \item Computing the cut score as the linearly interpolated item difficulty where the monotonized function crosses the specified boundary.
}

More formally, for a rater let \eqn{x_i} denote the item difficulty estimate and \eqn{r_i} the rating stage after conversion to the internal numeric scale. Items are first ordered such that \eqn{x_1 \leq \ldots \leq x_n}. Tied difficulties retain the order in which the items first occur in the input for smoothing. If ordinal labels are used, \code{rating_levels} defines the mapping to this internal scale; for example \code{c("1a", "1b", "2", "3", "4")} is mapped to \eqn{1, 2, 3, 4, 5}. Boundaries are specified on this internal scale, so \code{2.5} is the boundary between the second and third ordered rating level.

The smoothed value \eqn{z_i} is a symmetric moving average of order 1. For a sequence of at least three entries without missing values this is
\deqn{
z_i = \frac{r_{i-1} + r_i + r_{i+1}}{3},
}{
z_i = (r_{i-1} + r_i + r_{i+1}) / 3,
}
using padding values \eqn{r_0 = L_{\min}} and \eqn{r_{n+1} = L_{\max}} at the lower and upper end of the ordered series. Let \eqn{R} contain all finite internal ratings across all raters and \eqn{B} the supplied (or automatically derived) boundaries. The shared padding values are
\deqn{
L_{\min} = \min\{\min R, \lfloor\min B\rfloor\},
\qquad
L_{\max} = \max\{\max R, \lceil\max B\rceil\}.
}{
L_min = min(min(R), floor(min(B)));
L_max = max(max(R), ceiling(max(B))).
}
They are returned as \code{min_val} and \code{max_val} and also define the plot range. They are not computed separately for each rater. The function rejects input with no finite ratings at all.

With \code{missing = "drop"}, the moving average is applied to the compressed sequence of finite ratings. Thus the neighbors are the previous and next available ratings, possibly spanning missing items. The result is then placed back at the original item positions; missing rows remain missing in the smoothed and monotonized series. With \code{missing = "smooth"}, the full item sequence is retained and each window is averaged over its non-missing entries (including padding at the ends). This can fill a missing rating's smoothed value, but a window with no available entries yields \code{NA}. Smoothing is a single pass over the raw stages, not a recursive imputation. For fewer than three entries in the sequence being smoothed, values are returned unchanged and no padding is applied: this counts finite ratings for \code{"drop"} and all items for \code{"smooth"}.

The monotonized series \eqn{\hat y_i} is the isotonic least-squares fit
\deqn{
\hat y = \arg\min_{y_1 \leq \ldots \leq y_n} \sum_i (z_i - y_i)^2,
}{
yhat = argmin_{y_1 <= ... <= y_n} sum_i (z_i - y_i)^2,
}
computed with \code{\link[stats]{isoreg}} on finite smoothed values, with equal weight per retained item and the additional constraint \eqn{y_i = y_j} whenever \eqn{x_i = x_j}. The indices in this expression refer only to these retained values. Tied difficulty estimates receive the same fitted value. This step forces the estimated relationship between item difficulty and rating stage to be non-decreasing; distances between difficulty estimates do not weight the fit. If fewer than two finite smoothed values remain, the entire isotonic series and all cuts for that rater are \code{NA}.

For each boundary \eqn{b}, the function searches the finite fitted points and finds the first ordered point \eqn{i} with \eqn{\hat y_i \geq b}. If no such point exists, the cut is \code{NA}; the function does not extrapolate above the fitted range. If \eqn{i = 1}, the cut and its item position are those of the first retained point, including when the boundary is below the fitted range. Otherwise the cut is linearly interpolated between the two surrounding retained points:
\deqn{
\lambda = \frac{b - \hat y_{i-1}}{\hat y_i - \hat y_{i-1}},
\quad
c_b = x_{i-1} + \lambda (x_i - x_{i-1}).
}{
lambda = (b - yhat_{i-1}) / (yhat_i - yhat_{i-1});
c_b = x_{i-1} + lambda * (x_i - x_{i-1}).
}
\code{cuts_per_person} stores \eqn{c_b}, i.e. the cut on the item difficulty scale. The same interpolation factor is applied to the ordered item positions \eqn{p_i} to obtain
\deqn{
q_b = p_{i-1} + \lambda (p_i - p_{i-1}),
}{
q_b = p_{i-1} + lambda * (p_i - p_{i-1}),
}
which is stored in \code{cut_positions_per_person}. Here \eqn{p_i} is the position in the full ordered item list, even when missing ratings have been dropped. These positions can be non-integer, and interpolation can span missing items. If the boundary equals a fitted plateau, the first point on that plateau is used.

Cut score columns start with \code{cut}. Canonical numeric boundaries such as \code{1.5} and \code{2.5} are labelled as \code{cut12} and \code{cut23} for numeric ratings. With ordinal labels, labels such as \code{cut_1a_1b} are used. Non-canonical boundaries include the boundary value, for example \code{cut_1a_1b_bound1_3}.

\code{cut_statistics} reports the mean, sample standard deviation, and standard error across raters for both item positions (\code{page_*}) and difficulty cuts (\code{diff_*}). Standard errors are computed as \eqn{SE = SD / \sqrt{m}}, where \eqn{m} is the number of finite rater-specific cuts for that boundary. SD and SE are \code{NA} for fewer than two finite cuts; the mean is also \code{NA} if none exist. \code{cuts_summary} contains the unweighted mean difficulty cut per boundary, omitting missing cuts. These are means of individual cuts, not cuts computed from an averaged rating curve, and the contributing raters can differ by boundary. \code{level_statistics} uses the finite mean cuts as interval boundaries between the minimum and maximum item difficulty, counts each item once (including items with missing ratings), and reports the mean and sample standard deviation of item difficulties per level. Unavailable mean cuts are omitted. Intervals are left-closed and right-open, except for the final interval, which is closed on both sides. Empty intervals have \code{NA} means and SDs; intervals with one item have an \code{NA} SD.

The object also contains descriptive agreement diagnostics computed from the raw internal rating stages after the input has been normalized to the complete item-by-rater grid. These diagnostics do not enter the cut-score interpolation itself. \code{modal_values} reports the modal rating stage for each item. If several stages are tied for the highest frequency, \code{modal_stage} and \code{modal_label} are set to \code{NA}, while \code{modal_stages}, \code{modal_labels}, and \code{tie} retain the tie information. \code{rater_modal_correlations} correlates each rater's raw rating series with the item-wise modal values. It reports the correlation with the modal values based on all raters and, additionally, with leave-one-rater-out modal values so that the evaluated rater does not help define the criterion. Items without a unique modal value are omitted from the corresponding correlation.

Pairwise unweighted Cohen's kappa values are computed with \code{\link{meanKappa}} on the wide raw-rating matrix, using complete observations separately for each rater pair. \code{kappa_summary} gives the unweighted mean and sample standard deviation across finite pairwise kappa values, and \code{rater_kappa_statistics} gives the same information per rater across all pairings involving that rater. \code{fleiss_kappa} and \code{icc_statistics} are computed on item rows complete across all raters. The ICCs use a two-way model with single-measure agreement and consistency estimates. These diagnostics use raw ratings even with \code{missing = "smooth"}; smoothed values do not fill missing observations for agreement calculations. They summarize the rating round represented by the supplied data; the function does not select a round automatically. If the third IDM round should be analyzed, the input should contain that final round.

In \code{plot_data}, the residual is \eqn{r_i - z_i}, the raw rating minus its moving average, rather than minus the isotonic fit.
}
\value{
A \code{cutsIDM} object, i.e. a named list with:
\describe{
  \item{\code{cuts_per_person}}{One row per rater and one difficulty-scale cut column per boundary. Each cut is the first boundary crossing of that rater's smoothed, isotonic rating series, with linear interpolation on the difficulty scale as specified in Details. Unreached boundaries and raters with fewer than two finite smoothed values yield \code{NA}.}

  \item{\code{cut_positions_per_person}}{The same crossings expressed as positions in the full difficulty-ordered item list. The interpolation factor used for the difficulty cut is applied to the two surrounding item positions; missing items retain their positions in this list. Columns are named \code{page_*}.}

  \item{\code{cuts_summary}}{One row of unweighted arithmetic means of the finite rater-specific difficulty cuts, computed separately for each boundary. A boundary with no available cuts has mean \code{NA}.}

  \item{\code{cut_statistics}}{Rows \code{Mean}, \code{SD}, and \code{SE} for item-position cuts (\code{page_*}) and difficulty cuts (\code{diff_*}). For each column, \eqn{m} finite cuts contribute to the arithmetic mean, the sample SD from \code{\link[stats]{sd}} (denominator \eqn{m-1}), and \eqn{SE = SD / \sqrt{m}}. SD and SE are \code{NA} for \eqn{m < 2}; all three statistics are \code{NA} for \eqn{m = 0}.}

  \item{\code{level_statistics}}{Intervals formed from the minimum item difficulty, the finite mean cuts in boundary order, and the maximum item difficulty. For each interval, \code{n_items} counts distinct items, and \code{mean_itemdiff} and \code{sd_itemdiff} are their arithmetic mean and sample SD. Items at a cut enter the interval starting at that cut; the final interval also includes its upper endpoint. Empty intervals have \code{NA} means and SDs, and one-item intervals have \code{NA} SDs.}

  \item{\code{modal_values}}{Item-wise modes of the available raw internal rating stages. \code{n_ratings} counts available ratings, \code{modal_n} is the highest category count, and \code{modal_prop = modal_n / n_ratings}. A unique mode is returned in \code{modal_stage} and \code{modal_label}. Ties set these two fields to \code{NA}, while \code{modal_stages}, \code{modal_labels}, and \code{tie} retain the tied modes. Items without ratings have \code{n_ratings = 0}, missing mode fields and proportions, and \code{tie = FALSE}.}

  \item{\code{rater_modal_correlations}}{Pearson correlations computed with \code{\link[stats:cor]{stats::cor}} between each rater's raw numeric stages and the unique item modes. \code{cor_modal_all} uses modes from all raters; \code{cor_modal_leave_one_out} recomputes each mode without the evaluated rater. Each correlation uses only items with both a finite rating and a unique mode; the corresponding \code{n_items_*} column gives that count. Fewer than two usable items or zero variance in either series yields \code{NA}.}

  \item{\code{kappa_pairwise}}{One row per available rater pair, with \code{Coder1}, \code{Coder2}, the number \code{N} of jointly rated items, and \code{kappa}. The call \code{meanKappa(ratings, weight.mean = FALSE)} uses \code{\link[irr:kappa2]{irr::kappa2}} with \code{weight = "unweighted"} on each pair's complete raw ratings. Thus
  \deqn{\kappa = \frac{p_o - p_e}{1 - p_e}, \qquad p_e = \sum_k p_{1k}p_{2k}.}{kappa = (p_o - p_e) / (1 - p_e); p_e = sum_k p_1k * p_2k.}
  Here \eqn{p_o} is the proportion of exact agreements and \eqn{p_{1k}, p_{2k}} are the two raters' marginal proportions for category \eqn{k} on those items. All disagreements receive the same weight. Pairs without jointly rated items are omitted. As a special convention in \code{\link{meanKappa}}, an undefined kappa is replaced by 1 when the two retained rating vectors are identical. Fewer than two raters, no available pairs, or an error in the \code{meanKappa()} call yields an empty table.}

  \item{\code{kappa_summary}}{\code{mean_kappa} and \code{sd_kappa} are the arithmetic mean and sample SD of the finite entries in \code{kappa_pairwise$kappa}, with \code{n_pairs} giving their count. Every pair has equal weight, regardless of \code{N}. \code{mean_n_items} averages \code{N} over all returned pair rows, including rows with non-finite kappa. With no finite kappas, mean and SD are \code{NA}; with one finite kappa, SD is \code{NA}.}

  \item{\code{rater_kappa_statistics}}{The same calculations as in \code{kappa_summary}, restricted to pairs involving the respective rater. \code{n_pairs} counts finite kappas; \code{mean_n_items} averages item counts over all returned pairs involving that rater.}

  \item{\code{fleiss_kappa}}{One row from \code{\link[irr:kappam.fleiss]{irr::kappam.fleiss}} on raw-rating rows complete across all raters, using the defaults \code{exact = FALSE} and \code{detail = FALSE}. For \eqn{n} complete items, \eqn{J} raters, and category counts \eqn{n_{ik}} within item \eqn{i},
  \deqn{P_i = \frac{\sum_k n_{ik}(n_{ik}-1)}{J(J-1)}, \quad p_k = \frac{\sum_i n_{ik}}{nJ}, \quad \kappa = \frac{\bar P - \sum_k p_k^2}{1 - \sum_k p_k^2}.}{P_i = sum_k n_ik * (n_ik - 1) / (J * (J - 1)); p_k = sum_i n_ik / (n * J); kappa = (mean(P_i) - sum_k p_k^2) / (1 - sum_k p_k^2).}
  Here \eqn{\bar P} is the mean of \eqn{P_i}. This uses pooled category proportions. \code{kappa}, \code{statistic}, and \code{p_value} contain the coefficient, the z statistic, and its two-sided p-value for zero kappa returned by \code{irr}. \code{n_items} and \code{n_raters} record the matrix dimensions. Fewer than two complete items or raters yields \code{NA} estimates; calculation errors or non-finite results also yield \code{NA}.}

  \item{\code{icc_statistics}}{Two rows from \code{\link[irr:icc]{irr::icc}} on raw-rating rows complete across all raters: \code{model = "twoway"}, \code{unit = "single"}, and \code{type = "agreement"} or \code{"consistency"}. These give \code{ICC(A,1)} and \code{ICC(C,1)}. With \eqn{n} complete items, \eqn{J} raters, and two-way ANOVA mean squares \eqn{MS_I} (items), \eqn{MS_R} (raters), and \eqn{MS_E} (residual error),
  \deqn{ICC(A,1) = \frac{MS_I-MS_E}{MS_I+(J-1)MS_E+\frac{J}{n}(MS_R-MS_E)},}{ICC(A,1) = (MS_I - MS_E) / (MS_I + (J - 1) * MS_E + (J / n) * (MS_R - MS_E)),}
  \deqn{ICC(C,1) = \frac{MS_I-MS_E}{MS_I+(J-1)MS_E}.}{ICC(C,1) = (MS_I - MS_E) / (MS_I + (J - 1) * MS_E).}
  Agreement includes systematic differences between raters' means; consistency removes that component. The returned \code{f_value}, \code{df1}, \code{df2}, and \code{p_value} come from \code{irr}'s F-test with default \code{r0 = 0}; \code{conf_level}, \code{lbound}, and \code{ubound} describe its default 95\% confidence interval. \code{n_items} and \code{n_raters} record the matrix dimensions. Fewer than two complete items or raters, calculation errors, and non-finite results yield \code{NA} in the corresponding estimate fields.}

  \item{\code{plot_data}}{Long-format item identifiers and positions, raw internal stages (\code{stage_raw}), moving averages (\code{stage_sm}), isotonic fits (\code{stage_iso}), and residuals \code{stage_resid = stage_raw - stage_sm}, used by \code{plotCutsIDM()}. The smoothing and fitting steps are defined in Details.}

  \item{Metadata}{\code{boundaries}, \code{cut_labels}, \code{min_val}, \code{max_val}, \code{est_col}, \code{item_id_col}, \code{rater_cols}, and further input settings used by \code{plotCutsIDM()}. \code{min_val} and \code{max_val} are the shared padding values defined in Details.}
}
All modal, correlation, kappa, and ICC results use raw internal rating stages; smoothing does not impute missing ratings for these diagnostics.

\code{summary()} can be used to print the main cut score, boundary, and level-statistic tables in a compact form.
}
\examples{
## Wide-format input with numeric rating stages
dat <- data.frame(
  est = seq(100, 800, by = 100),
  Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5),
  Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5)
)

cuts <- computeCutsIDM(dat, boundaries = c(1.5, 2.5, 3.5))
cuts$cuts_per_person
cuts$cuts_summary
cuts$cut_statistics
cuts$level_statistics
cuts$modal_values
cuts$rater_kappa_statistics
cuts$fleiss_kappa
cuts$icc_statistics
summary(cuts)

## Long-format input with ordinal rating labels
long_dat <- data.frame(
  item = rep(paste0("item_", 1:5), 2),
  theta = rep(seq(100, 500, by = 100), 2),
  rater = rep(c("Meyer", "Schmidt"), each = 5),
  rating = c(
    "1a", "1b", "2", "3", "4",
    "1a", "1b", "2", "3", "4"
  )
)

ord_cuts <- computeCutsIDM(
  long_dat,
  item_id_col = "item",
  est_col = "theta",
  rater_id_col = "rater",
  rating_col = "rating",
  rating_levels = c("1a", "1b", "2", "3", "4")
)

ord_cuts$cuts_summary
ord_cuts$modal_values
names(ord_cuts$cuts_per_person)
}
