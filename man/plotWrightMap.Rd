\name{plotWrightMap}
\alias{plotWrightMap}
\title{Plot a Classical Wright Map from Item Difficulties and Plausible Values}
\description{
Displays a vertical person distribution on the left and item names on the right,
separated by a continuous vertical line. A softly filled teal distribution,
subtle guides, and grouped item labels share a white background. Items on the
same display stage are separated by \code{ | } and wrap with a hanging indent.
All supplied scores must already share one metric and dimension.
}
\usage{
plotWrightMap(
  items, pv_data, item_col = "item", difficulty_col = "difficulty",
  pv_cols = NULL, respondent_id_col = NULL,
  pv_id_col = NULL, pv_value_col = NULL, weight_col = NULL,
  input_format = c("auto", "long", "wide"),
  pv_missing = c("error", "drop"),
  person_geom = c("density", "histogram"),
  density_bw = NULL, density_adjust = 1, binwidth = NULL,
  item_step = NULL, item_origin = 0,
  person_prop = 0.35, item_size = 3, base_size = 11,
  font_family = "", score_label = "Score", score_limits = NULL,
  person_label = "Persons", item_label = "Items", title = NULL,
  category_col = "category", person_fill = "#DDECEB",
  person_colour = "#327D83", item_colour = "#293B44",
  line_colour = "#A7B5BD"
)
}
\arguments{
  \item{items}{A named, finite numeric vector of item difficulties, or a data
  frame with columns selected by \code{item_col} and \code{difficulty_col}.
  Names must be non-empty and cannot contain tabs, newlines, or \code{|}.
  Vector names must be unique. Repeated identifiers in a table are disambiguated
  using \code{category_col}. Factor name columns are accepted. No item parameter
  conversion is performed.}
  \item{pv_data}{Data frame containing plausible values for one population and
  one dimension. PVs and item difficulties must already be on the same scale;
  this cannot be verified from numeric values alone.}
  \item{item_col, difficulty_col}{Distinct column names for item names and
  difficulties when \code{items} is a data frame. Ignored for a named vector.}
  \item{category_col}{Category column to consult only when item identifiers
  repeat, default \code{"category"}. For every repeated identifier, categories
  must be non-missing, non-empty character, factor, or finite numeric values.
  The combination of identifier and category must be unique. Only repeated
  identifiers receive a \code{_cat<category>} suffix, for example
  \code{Item_03_cat1}. Categories on unique identifiers are ignored and may be
  missing; the column need not exist if all identifiers are unique. Tabs,
  newlines, \code{|}, and collisions between resulting display names are
  rejected. The category column must differ from the identifier and difficulty
  columns. \code{NULL} disables category lookup and rejects repeated identifiers.}
  \item{pv_cols}{Explicit character vector of numeric PV column names for wide
  input, with one row per respondent. Required for wide input.}
  \item{respondent_id_col}{Optional respondent ID column for wide input;
  required for long input.}
  \item{pv_id_col, pv_value_col}{PV identifier and numeric score columns for
  long input. Each respondent-PV combination must be unique.}
  \item{weight_col}{Optional sampling-weight column. Weights must be finite,
  non-missing, non-negative, and constant across a respondent's PVs. Zero-weight
  rows are excluded; \code{NULL} assigns equal weights.}
  \item{input_format}{\code{"auto"} chooses long input when \code{pv_id_col}
  or \code{pv_value_col} is supplied, and wide input otherwise.}
  \item{pv_missing}{\code{"error"} rejects missing PV values or respondent-PV
  rows. \code{"drop"} omits them with a warning and renormalizes weights
  within each PV. Each PV requires at least two observed respondents with
  positive weights. Infinite scores and invalid weights always cause errors.}
  \item{person_geom}{Person distribution: \code{"density"} (default) or
  \code{"histogram"}. Both grow to the left from the central divider.}
  \item{density_bw}{Optional positive common bandwidth in score units, used
  only for density plots. The default averages unweighted \code{bw.nrd0}
  bandwidths across PVs; sampling weights enter the density estimates.}
  \item{density_adjust}{Positive multiplier for the density bandwidth.}
  \item{binwidth}{Positive histogram bin width in score units. Defaults to a
  pretty step targeting approximately 30 bins across the observed PV range.
  Bins are aligned to zero, left-closed and right-open, and cover all observed
  positive-weight PVs. At most 10000 bins are allowed. Used only for histograms.}
  \item{item_step}{Non-negative distance between item display stages. By
  default a pretty step targets approximately 30 intervals across the combined
  range of item difficulties and observed positive-weight PVs. Use \code{0}
  to display exact difficulties, grouping only identical values. Positive steps
  assign items to the nearest stage; exact halfway values go to the upper stage
  subject to floating-point precision.}
  \item{item_origin}{Finite origin of the item stage grid, default \code{0}.
  Ignored when \code{item_step = 0}.}
  \item{person_prop}{Approximate proportion of panel width reserved for the
  person distribution, between 0.1 and 0.9. The remainder is used for item
  labels. A small additional margin is reserved to the left of the curve.}
  \item{item_size}{Maximum item-label text size in millimetres. Labels wrap
  between complete item names to fit the final device width. Continuation lines
  have a hanging indent and start with \code{|}; a bracket groups each block.
  Blocks are positioned near their stages without overlap, with leaders back to
  exact stage markers on the divider. Text is reduced uniformly only if all
  blocks cannot fit the panel or a single name is too wide. For extremely dense
  maps, increase the output size or adjust \code{person_prop} and \code{item_step}.}
  \item{base_size}{Base theme font size in points.}
  \item{font_family}{Font family used for both item labels and theme text.}
  \item{score_label}{Vertical metric label, or \code{NULL}.}
  \item{score_limits}{Optional finite, increasing pair of vertical display
  limits. These zoom the plot without changing the computed population
  estimates or item stages. Defaults to the full distribution and item range
  with padding. Labels outside the visible range are omitted from drawing.}
  \item{person_label, item_label}{Headings above the person and item sides,
  respectively. Use \code{NULL} to omit a heading.}
  \item{title}{Optional plot title.}
  \item{person_fill, person_colour}{Fill and outline colours of the person
  distribution. \code{person_colour} also colours the item stage markers.}
  \item{item_colour}{Item text and heading colour.}
  \item{line_colour}{Colour of the divider, item leaders, and grouping brackets.
  All four colour arguments accept a single valid R colour.}
}
\details{
The vertical scale increases upwards. The horizontal size of the distribution
shows its shape, normalized to a maximum panel width; it does not represent
sample counts. There is no fixed aspect ratio, so either portrait or landscape
output can be used.

Densities are estimated separately for each PV with normalized sampling weights
on a common grid and bandwidth, then averaged with equal weight for each PV.
Histograms likewise average per-PV weighted relative frequencies on common bins.
PVs are never averaged within respondents before estimating the distribution.
The shared PV input validation and density calculation are also used by
\code{\link{plotPopulationCuts}}.

Item stages affect display only. For a positive step, the displayed position is
\code{item_origin + item_step * floor((difficulty - item_origin) / item_step + 0.5)}.
The maximum displacement is half a step, apart from floating-point precision.
Items within a stage retain their input order. Original difficulties remain
available in the returned data. Category-specific parameters may be supplied
with repeated identifiers plus a category column, or with already unique names.
The function does not derive thresholds. Text blocks may move to avoid overlap;
their stage markers and the population distribution retain their score positions.
}
\value{
A \code{ggplot} object that can be customized and saved with
\code{ggplot2::ggsave()}. Its \code{"wright_data"} attribute is a list containing:
\describe{
  \item{items}{Input-order data frame with displayed \code{item}, original
  \code{item_id}, \code{category} (\code{NA} for unique identifiers), original
  \code{difficulty}, and displayed \code{stage}.}
  \item{item_labels}{Sorted display stages and their combined \code{label}.}
  \item{population}{For density plots, \code{score} and mean \code{density}.
  For histograms, \code{lower}, \code{upper}, mean bin \code{proportion}, and
  \code{density} (proportion divided by bin width). These values precede
  horizontal scaling for display.}
  \item{person_geom, item_step, item_origin, binwidth}{Resolved plotting
  settings; \code{binwidth} is \code{NULL} for density plots.}
}
}
\examples{
set.seed(42)
persons <- data.frame(
  id = 1:200,
  PV1 = rnorm(200), PV2 = rnorm(200), PV3 = rnorm(200),
  weight = runif(200, 0.5, 2)
)
items <- data.frame(
  item = c("Item_01", "Item_02", "Item_03", "Item_03", "Item_04"),
  category = c(NA, NA, 1, 2, NA),
  difficulty = c(-1.5, -0.45, 0.02, 0.85, 0.95)
)

p <- plotWrightMap(items, persons, pv_cols = paste0("PV", 1:3),
                   weight_col = "weight", item_step = 0.25)
p
attr(p, "wright_data")$items

# Named vector and optional histogram.
plotWrightMap(c(A = -1, B = 0, C = 1), persons,
              pv_cols = paste0("PV", 1:3), person_geom = "histogram",
              binwidth = 0.25)

# The equivalent long PV layout.
long <- tidyr::pivot_longer(persons, c("PV1", "PV2", "PV3"),
                            names_to = "pv", values_to = "score")
plotWrightMap(items, long, respondent_id_col = "id",
              pv_id_col = "pv", pv_value_col = "score", weight_col = "weight")
}
\seealso{\code{\link{plotPopulationCuts}}, \code{\link{plotPopulationCutsIDM}}}
