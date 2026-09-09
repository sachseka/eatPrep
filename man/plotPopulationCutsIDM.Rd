\name{plotPopulationCutsIDM}
\alias{plotPopulationCutsIDM}
\title{Plot a Population Distribution from Plausible Values with IDM Cuts}
\description{
Estimates a population density from wide- or long-format plausible values (PVs)
and draws IDM cut scores over it. The y-axis represents population density.
For a distribution-shape silhouette behind rater curves, use \code{\link{plotCutsIDM}}.
}
\usage{
plotPopulationCutsIDM(
  res_list,
  pv_data,
  pv_cols = NULL,
  respondent_id_col = NULL,
  pv_id_col = NULL,
  pv_value_col = NULL,
  weight_col = NULL,
  input_format = c("auto", "long", "wide"),
  pv_missing = c("error", "drop"),
  density_bw = NULL,
  density_adjust = 1,
  cut_selection = c("mean", "individual", "both"),
  est_col = NULL,
  show_cut_values = TRUE,
  cut_value_digits = 0L,
  cut_value_size = 2.6,
  population_fill = "grey50",
  population_alpha = 0.25
)
}
\arguments{
  \item{res_list}{A list returned by \code{\link{computeCutsIDM}}. Cut scores are used as stored, without re-estimation.}
  \item{pv_data}{A data frame of plausible values for one population and one domain. PVs must already use the same metric as the item estimates and cuts. No scale conversion is performed.}
  \item{pv_cols}{Character vector of PV column names for wide input, with one row per respondent. Required for wide input; other numeric columns are never selected automatically.}
  \item{respondent_id_col}{Optional respondent ID column for wide input; required for long input. Wide IDs must be unique. IDs are population respondent identifiers, not rater or item identifiers.}
  \item{pv_id_col}{PV identifier column for long input, for example a column containing \code{"PV1"}, \code{"PV2"}, and so on. Required together with \code{pv_value_col} and \code{respondent_id_col}. Each respondent-PV combination must be unique.}
  \item{pv_value_col}{Numeric PV value column for long input.}
  \item{weight_col}{Optional numeric sampling-weight column. Default \code{NULL} uses equal weights. Weights must be finite, non-missing, non-negative, and constant across PVs for each respondent. Zero-weight observations are excluded.}
  \item{input_format}{Input layout. \code{"auto"} selects long format when \code{pv_id_col} or \code{pv_value_col} is supplied, and wide format otherwise. Supply only the column selectors for the chosen layout.}
  \item{pv_missing}{Missing-PV policy. Default \code{"error"} rejects \code{NA}/\code{NaN} values and omitted respondent-PV rows. \code{"drop"} omits these with a warning and renormalizes weights separately within each PV. Infinite PVs and missing or invalid weights always cause an error. Every PV must retain at least two observed respondents with positive weights.}
  \item{density_bw}{Optional positive finite numeric bandwidth in score units. When \code{NULL}, use the mean of the unweighted \code{stats::bw.nrd0()} bandwidths calculated separately for each PV after exclusions. This common bandwidth is used for every PV; automatic bandwidth selection does not account for sampling weights.}
  \item{density_adjust}{Positive finite multiplier for the common bandwidth. Values above one produce more smoothing; values below one produce less.}
  \item{cut_selection}{\code{"mean"} (default) draws cuts from \code{res_list$cuts_summary}. \code{"individual"} creates one facet per rater with cuts from \code{res_list$cuts_per_person}. \code{"both"} adds a mean-cut facet to the individual facets. All facets show the same population density on fixed axes.}
  \item{est_col}{Optional x-axis metric label. Defaults to \code{res_list$est_col}, or \code{"est"} if unavailable. This changes the label only.}
  \item{show_cut_values}{Logical scalar. Show numeric labels next to finite cut lines.}
  \item{cut_value_digits}{Non-negative integer scalar. Digits after the decimal point for rounding cut labels; trailing zeros are removed. Default \code{0L}.}
  \item{cut_value_size}{Finite non-negative cut-label text size in millimetres. Default \code{2.6}.}
  \item{population_fill}{Color for the density fill and outline. Default \code{"grey50"}.}
  \item{population_alpha}{Finite fill opacity between zero and one. Default \code{0.25}.}
}
\details{
A Gaussian kernel density is estimated separately for each PV, using sampling
weights normalized to sum to one within that PV. These densities are averaged
with equal weight across PVs. All estimates use a common bandwidth and a shared
512-point grid extending three bandwidths beyond the observed PV range.
Respondents' PVs are never averaged before estimating the distribution. The
automatic bandwidth is based on the respondent count within each PV, not on the
number of stacked PV observations.

This is a descriptive density estimate. It does not compute confidence intervals,
replicate-weight variances, or the proportions between cuts. Sampling weights
affect the estimated density, but not the automatic bandwidth rule. An explicit
\code{density_bw} can be supplied when a different smoothing choice is needed.
With \code{pv_missing = "drop"}, different PVs may use different respondent
subsets; missing cases are not imputed. A PV entirely absent from long input
cannot be detected, so include every intended PV identifier in the input.

PVs and cuts are drawn directly on their supplied score metric. The x-range
includes the density grid and all finite selected cuts. The density is repeated
unchanged across rater and mean facets; it is not conditioned on the rater.

Here the y-axis is population density. In contrast, the optional background in
\code{plotCutsIDM()} is a silhouette showing \strong{distribution shape only}:
its height is scaled for display and \strong{does not represent rating stages}
or density-axis values. Use this standalone plot when the density axis matters.
Both functions use the same population preparation and density calculation.
}
\value{
A \code{ggplot2} object that can be customized with standard ggplot layers and themes.
}
\seealso{
\code{\link{computeCutsIDM}}, \code{\link{plotCutsIDM}}, \code{\link[stats]{density}}.
}
\references{
OECD, \emph{PISA Research Documentation: How to prepare and analyse the PISA database}.
\url{https://www.oecd.org/en/about/programmes/pisa/how-to-prepare-and-analyse-the-pisa-database.html}
}
\examples{
items <- data.frame(
  est = seq(100, 800, by = 100),
  Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5),
  Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5)
)
cuts <- computeCutsIDM(items, boundaries = c(1.5, 2.5, 3.5))

## Synthetic PVs on the same score metric as the item estimates and cuts.
set.seed(42)
population <- data.frame(
  student = seq_len(200),
  PV1 = rnorm(200, 450, 100),
  PV2 = rnorm(200, 450, 100),
  weight = runif(200, 0.5, 2)
)

## Standalone density with mean cuts: the y-axis represents density.
plotPopulationCutsIDM(cuts, population, pv_cols = c("PV1", "PV2"),
                      weight_col = "weight")

## Compare individual and mean cuts over the same population distribution.
plotPopulationCutsIDM(cuts, population, pv_cols = c("PV1", "PV2"),
                      weight_col = "weight", cut_selection = "both",
                      density_adjust = 1.2, cut_value_size = 3)

## Equivalent long input: one row per respondent and PV.
population_long <- tidyr::pivot_longer(
  population, cols = c("PV1", "PV2"),
  names_to = "pv", values_to = "score"
)
plotPopulationCutsIDM(cuts, population_long,
                      respondent_id_col = "student",
                      pv_id_col = "pv", pv_value_col = "score",
                      weight_col = "weight")

## Background silhouette: distribution shape only.
## Its height does NOT represent rating stages or density-axis values.
plotCutsIDM(cuts, pv_data = population, pv_cols = c("PV1", "PV2"),
            weight_col = "weight", show_aggregate = TRUE,
            population_height = 0.25, population_alpha = 0.15)
}
