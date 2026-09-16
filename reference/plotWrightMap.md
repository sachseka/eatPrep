# Plot a Classical Wright Map from Item Difficulties and Plausible Values

Displays a vertical person distribution on the left and item names on
the right, separated by a continuous vertical line. A softly filled teal
distribution, subtle guides, and grouped item labels share a white
background. Items on the same display stage are separated by ` | ` and
wrap with a hanging indent. All supplied scores must already share one
metric and dimension.

## Usage

``` r
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
```

## Arguments

- items:

  A named, finite numeric vector of item difficulties, or a data frame
  with columns selected by `item_col` and `difficulty_col`. Names must
  be non-empty and cannot contain tabs, newlines, or `|`. Vector names
  must be unique. Repeated identifiers in a table are disambiguated
  using `category_col`. Factor name columns are accepted. No item
  parameter conversion is performed.

- pv_data:

  Data frame containing plausible values for one population and one
  dimension. PVs and item difficulties must already be on the same
  scale; this cannot be verified from numeric values alone.

- item_col, difficulty_col:

  Distinct column names for item names and difficulties when `items` is
  a data frame. Ignored for a named vector.

- category_col:

  Category column to consult only when item identifiers repeat, default
  `"category"`. For every repeated identifier, categories must be
  non-missing, non-empty character, factor, or finite numeric values.
  The combination of identifier and category must be unique. Only
  repeated identifiers receive a `_cat<category>` suffix, for example
  `Item_03_cat1`. Categories on unique identifiers are ignored and may
  be missing; the column need not exist if all identifiers are unique.
  Tabs, newlines, `|`, and collisions between resulting display names
  are rejected. The category column must differ from the identifier and
  difficulty columns. `NULL` disables category lookup and rejects
  repeated identifiers.

- pv_cols:

  Explicit character vector of numeric PV column names for wide input,
  with one row per respondent. Required for wide input.

- respondent_id_col:

  Optional respondent ID column for wide input; required for long input.

- pv_id_col, pv_value_col:

  PV identifier and numeric score columns for long input. Each
  respondent-PV combination must be unique.

- weight_col:

  Optional sampling-weight column. Weights must be finite, non-missing,
  non-negative, and constant across a respondent's PVs. Zero-weight rows
  are excluded; `NULL` assigns equal weights.

- input_format:

  `"auto"` chooses long input when `pv_id_col` or `pv_value_col` is
  supplied, and wide input otherwise.

- pv_missing:

  `"error"` rejects missing PV values or respondent-PV rows. `"drop"`
  omits them with a warning and renormalizes weights within each PV.
  Each PV requires at least two observed respondents with positive
  weights. Infinite scores and invalid weights always cause errors.

- person_geom:

  Person distribution: `"density"` (default) or `"histogram"`. Both grow
  to the left from the central divider.

- density_bw:

  Optional positive common bandwidth in score units, used only for
  density plots. The default averages unweighted `bw.nrd0` bandwidths
  across PVs; sampling weights enter the density estimates.

- density_adjust:

  Positive multiplier for the density bandwidth.

- binwidth:

  Positive histogram bin width in score units. Defaults to a pretty step
  targeting approximately 30 bins across the observed PV range. Bins are
  aligned to zero, left-closed and right-open, and cover all observed
  positive-weight PVs. At most 10000 bins are allowed. Used only for
  histograms.

- item_step:

  Non-negative distance between item display stages. By default a pretty
  step targets approximately 30 intervals across the combined range of
  item difficulties and observed positive-weight PVs. Use `0` to display
  exact difficulties, grouping only identical values. Positive steps
  assign items to the nearest stage; exact halfway values go to the
  upper stage subject to floating-point precision.

- item_origin:

  Finite origin of the item stage grid, default `0`. Ignored when
  `item_step = 0`.

- person_prop:

  Approximate proportion of panel width reserved for the person
  distribution, between 0.1 and 0.9. The remainder is used for item
  labels. A small additional margin is reserved to the left of the
  curve.

- item_size:

  Maximum item-label text size in millimetres. Labels wrap between
  complete item names to fit the final device width. Continuation lines
  have a hanging indent and start with `|`; a bracket groups each block.
  Blocks are positioned near their stages without overlap, with leaders
  back to exact stage markers on the divider. Text is reduced uniformly
  only if all blocks cannot fit the panel or a single name is too wide.
  For extremely dense maps, increase the output size or adjust
  `person_prop` and `item_step`.

- base_size:

  Base theme font size in points.

- font_family:

  Font family used for both item labels and theme text.

- score_label:

  Vertical metric label, or `NULL`.

- score_limits:

  Optional finite, increasing pair of vertical display limits. These
  zoom the plot without changing the computed population estimates or
  item stages. Defaults to the full distribution and item range with
  padding. Labels outside the visible range are omitted from drawing.

- person_label, item_label:

  Headings above the person and item sides, respectively. Use `NULL` to
  omit a heading.

- title:

  Optional plot title.

- person_fill, person_colour:

  Fill and outline colours of the person distribution. `person_colour`
  also colours the item stage markers.

- item_colour:

  Item text and heading colour.

- line_colour:

  Colour of the divider, item leaders, and grouping brackets. All four
  colour arguments accept a single valid R colour.

## Details

The vertical scale increases upwards. The horizontal size of the
distribution shows its shape, normalized to a maximum panel width; it
does not represent sample counts. There is no fixed aspect ratio, so
either portrait or landscape output can be used.

Densities are estimated separately for each PV with normalized sampling
weights on a common grid and bandwidth, then averaged with equal weight
for each PV. Histograms likewise average per-PV weighted relative
frequencies on common bins. PVs are never averaged within respondents
before estimating the distribution. The shared PV input validation and
density calculation are also used by
[`plotPopulationCuts`](https://sachseka.github.io/eatPrep/reference/plotPopulationCuts.md).

Item stages affect display only. For a positive step, the displayed
position is
`item_origin + item_step * floor((difficulty - item_origin) / item_step + 0.5)`.
The maximum displacement is half a step, apart from floating-point
precision. Items within a stage retain their input order. Original
difficulties remain available in the returned data. Category-specific
parameters may be supplied with repeated identifiers plus a category
column, or with already unique names. The function does not derive
thresholds. Text blocks may move to avoid overlap; their stage markers
and the population distribution retain their score positions.

## Value

A `ggplot` object that can be customized and saved with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html).
Its `"wright_data"` attribute is a list containing:

- items:

  Input-order data frame with displayed `item`, original `item_id`,
  `category` (`NA` for unique identifiers), original `difficulty`, and
  displayed `stage`.

- item_labels:

  Sorted display stages and their combined `label`.

- population:

  For density plots, `score` and mean `density`. For histograms,
  `lower`, `upper`, mean bin `proportion`, and `density` (proportion
  divided by bin width). These values precede horizontal scaling for
  display.

- person_geom, item_step, item_origin, binwidth:

  Resolved plotting settings; `binwidth` is `NULL` for density plots.

## See also

[`plotPopulationCuts`](https://sachseka.github.io/eatPrep/reference/plotPopulationCuts.md),
[`plotPopulationCutsIDM`](https://sachseka.github.io/eatPrep/reference/plotPopulationCutsIDM.md)

## Examples

``` r
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
#>           item item_id category difficulty stage
#> 1      Item_01 Item_01     <NA>      -1.50 -1.50
#> 2      Item_02 Item_02     <NA>      -0.45 -0.50
#> 3 Item_03_cat1 Item_03        1       0.02  0.00
#> 4 Item_03_cat2 Item_03        2       0.85  0.75
#> 5      Item_04 Item_04     <NA>       0.95  1.00

# Named vector and optional histogram.
plotWrightMap(c(A = -1, B = 0, C = 1), persons,
              pv_cols = paste0("PV", 1:3), person_geom = "histogram",
              binwidth = 0.25)


# The equivalent long PV layout.
long <- tidyr::pivot_longer(persons, c("PV1", "PV2", "PV3"),
                            names_to = "pv", values_to = "score")
plotWrightMap(items, long, respondent_id_col = "id",
              pv_id_col = "pv", pv_value_col = "score", weight_col = "weight")
```
