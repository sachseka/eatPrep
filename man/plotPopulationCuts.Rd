\name{plotPopulationCuts}
\alias{plotPopulationCuts}
\title{Plot Population Distributions with Supplied Cut Scores}
\description{
Plots a population density estimated from plausible values (PVs), with supplied
numeric cut scores and percentage shares for the resulting intervals. No IDM
result object is needed. Supports the same PV layouts, weights, population
groups, and display options as \code{\link{plotPopulationCutsIDM}}.
}
\usage{
plotPopulationCuts(
  cuts, pv_data, pv_cols = NULL,
  respondent_id_col = NULL,
  pv_id_col = NULL, pv_value_col = NULL,
  weight_col = NULL,
  input_format = c("auto", "long", "wide"),
  pv_missing = c("error", "drop"),
  density_bw = NULL, density_adjust = 1,
  cut_labels = NULL, est_col = NULL,
  show_cut_values = TRUE,
  cut_value_digits = 0L, cut_value_size = 2.6,
  population_fill = "grey50", population_alpha = 0.25,
  population_col = NULL, population_colors = NULL,
  show_percentages = TRUE, percentage_digits = 1L,
  percentage_size = 3,
  show_population_stats = TRUE, population_stats_digits = 2L,
  show_caption = FALSE, jk2 = NULL
)
}
\arguments{
  \item{cuts}{Non-empty, finite numeric vector of strictly increasing cut scores,
  on the same scale as the PVs. Missing, duplicate, or unsorted cuts are rejected.
  Vector names are ignored; use \code{cut_labels} to label the cut lines.}
  \item{pv_data}{Data frame of plausible values for one domain, optionally
  containing multiple populations. No scale conversion is performed.}
  \item{pv_cols}{Explicit character vector of PV columns for wide input, with
  one row per respondent. Required for wide input.}
  \item{respondent_id_col}{Optional respondent ID column for wide input;
  required for long input. IDs must be unique within each population in wide input.}
  \item{pv_id_col}{PV identifier column for long input. Each respondent-PV
  combination must be unique within its population.}
  \item{pv_value_col}{Numeric PV value column for long input.}
  \item{weight_col}{Optional numeric sampling-weight column. Weights must be
  finite, non-missing, non-negative, and constant across each respondent's PVs.
  Zero-weight observations are excluded. Default \code{NULL} uses equal weights.}
  \item{input_format}{\code{"auto"} selects long input when \code{pv_id_col}
  or \code{pv_value_col} is supplied, and wide input otherwise.}
  \item{pv_missing}{\code{"error"} rejects missing PV values or respondent-PV
  rows. \code{"drop"} omits them with a warning and renormalizes weights within
  each PV and population. Each PV requires at least two observed respondents
  with positive weights. Infinite PVs and invalid weights always cause an error.}
  \item{density_bw}{Optional positive finite bandwidth in score units. The
  default averages unweighted \code{stats::bw.nrd0()} bandwidths across PVs
  within populations, then across populations. See \code{\link{plotPopulationCutsIDM}}.}
  \item{density_adjust}{Positive finite multiplier for the common bandwidth.}
  \item{cut_labels}{Optional character vector with one unique, non-empty label
  per cut, in cut order. Defaults to \code{"cut1"}, \code{"cut2"}, etc.
  These label cut lines in the legend, not intervals.}
  \item{est_col}{Optional x-axis metric label. Default \code{NULL} labels the
  axis \code{"Score"}; otherwise the label is \code{"Score (<est_col>)"}.}
  \item{show_cut_values}{Show numeric labels next to cut lines.}
  \item{cut_value_digits}{Non-negative integer number of decimal places in cut
  labels. Trailing zeros are removed. This does not change interval membership.}
  \item{cut_value_size}{Non-negative cut-label text size in millimetres.}
  \item{population_fill}{Density fill and outline color, or one color per
  population in order of first appearance. If omitted, grouped input uses an
  automatic palette. An incorrect color count warns and restores defaults.}
  \item{population_alpha}{Fill opacity between zero and one.}
  \item{population_col}{Optional grouping column. Population identifiers must
  be non-missing and non-empty. Densities and percentages are estimated separately
  within each population, in order of first appearance.}
  \item{population_colors}{Optional named color vector with exactly one color
  for each population. Requires \code{population_col}; takes precedence over
  \code{population_fill}.}
  \item{show_percentages}{Show interval percentages above the density panel.
  Hiding labels does not suppress the returned percentage table.}
  \item{percentage_digits}{Integer from zero to ten specifying decimal places
  in displayed percentages. Rounding may make displayed totals differ from 100.}
  \item{percentage_size}{Non-negative percentage text size in millimetres.}
  \item{show_population_stats}{Show population mean and SD in the population
  legend, or subtitle for ungrouped input.}
  \item{population_stats_digits}{Integer from zero to ten specifying decimal
  places in displayed mean and SD.}
  \item{show_caption}{Show explanatory captions. Defaults to \code{FALSE}.}
  \item{jk2}{Optional list with exactly two column names, for example
  \code{list(PSU = "jkzone", repInd = "jkrep")}, enabling eatRep JK2 estimation
  of interval percentages and standard errors. \code{PSU} identifies the JK zone;
  \code{repInd} must be numeric 0/1. Both must be non-missing and constant across
  each respondent's PVs, and distinct from other input columns. Default
  \code{NULL} preserves the descriptive calculation without requiring eatRep.
  See \code{\link{plotPopulationCutsIDM}} for design and pooling details.}
}
\details{
Gaussian kernel densities are estimated separately for each PV using normalized
sampling weights, then averaged equally across PVs. Populations share a common
bandwidth and grid, and each density has area one. PVs are never averaged within
respondents before estimation.

Percentages are computed directly from observed PVs, independently of density
smoothing. For each population and PV, the weights in each interval are divided
by that PV's total available weight and multiplied by 100. These percentages
are then averaged equally across PVs. With cuts \eqn{c_1, \ldots, c_K}, intervals
are \eqn{(-\infty, c_1)}, \eqn{[c_1, c_2)}, through \eqn{[c_K, \infty)}.
Equality belongs to the upper interval. All available values contribute,
including values outside the visible plot range. Missing-value dropping
renormalizes weights within each PV and population.

Population means average the per-PV weighted means. SD is the square root of
the average per-PV variance, with the \eqn{n/(n-1)} correction applied within
each PV and population. See \code{\link{plotPopulationCutsIDM}} for details of
estimation, missing-data handling, colors, and percentage-label placement.
}
\value{
A \code{ggplot} object that can be printed, customized, or saved with
\code{ggplot2::ggsave()}. Its \code{"population_percentages"} attribute is a
data frame with columns \code{population}, \code{interval} (starting at one),
\code{lower}, \code{upper}, and \code{percentage} (unrounded, from zero to 100).
Outer bounds are infinite. Ungrouped input uses the population label
\code{"Population"}. The table is calculated even if \code{show_percentages = FALSE}.
Extract it with \code{attr(p, "population_percentages")} before further plot
customization. With \code{jk2 = NULL}, these are descriptive shares without
standard errors, and the table retains its original five columns. With JK2
enabled, an additional \code{se} column contains the pooled standard error in
percentage points. Densities and population M/SD remain descriptive estimates.
}
\examples{
pvs <- data.frame(
  PV1 = c(100, 230, 360, 460),
  PV2 = c(230, 360, 460, 600),
  weight = c(1, 2, 3, 4)
)
p <- plotPopulationCuts(
  cuts = c(230, 360, 460), pv_data = pvs,
  pv_cols = c("PV1", "PV2"), weight_col = "weight"
)
p
attr(p, "population_percentages")

if (requireNamespace("eatRep", quietly = TRUE)) {
  jk_pvs <- data.frame(
    id = 1:12, PV1 = rep(c(100, 300, 400, 500), 3),
    PV2 = rep(c(300, 100, 500, 400), 3), weight = rep(1:3, 4),
    jkzone = rep(1:3, each = 4), jkrep = rep(c(0, 0, 1, 1), 3)
  )
  p_jk2 <- plotPopulationCuts(
    c(230, 360, 460), jk_pvs, pv_cols = c("PV1", "PV2"),
    respondent_id_col = "id", weight_col = "weight",
    jk2 = list(PSU = "jkzone", repInd = "jkrep")
  )
  attr(p_jk2, "population_percentages")
}

long_pvs <- data.frame(
  id = rep(1:4, times = 2), pv = rep(c("PV1", "PV2"), each = 4),
  score = c(pvs$PV1, pvs$PV2)
)
plotPopulationCuts(
  c(230, 360, 460), long_pvs,
  respondent_id_col = "id", pv_id_col = "pv", pv_value_col = "score"
)
}
\seealso{\code{\link{plotPopulationCutsIDM}}, \code{\link{plotCutsIDM}}}
