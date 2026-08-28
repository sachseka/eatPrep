\name{plotCutsIDM}
\alias{plotCutsIDM}
\title{Plot Raw Values, Moving Average, and Monotonized Moving Average}
\description{
Visualizes the IDM rating process for each rater, showing raw ratings, smoothed moving averages, the final isotonic regression line used to determine cut scores, and optionally filter residuals.
}
\usage{
plotCutsIDM(
  res_list,
  est_col = NULL,
  show_raw = TRUE,
  show_smoothed = TRUE,
  show_residuals = FALSE,
  show_aggregate = FALSE,
  show_aggregate_labels = TRUE
)
}
\arguments{
  \item{res_list}{A list returned by \code{computeCutsIDM()} containing the processed data and cut score coordinates.}
  \item{est_col}{Optional character scalar. Label to use for the item difficulty axis. If \code{NULL}, the value stored by \code{computeCutsIDM()} is used.}
  \item{show_raw}{Logical scalar. If \code{TRUE}, raw ratings are shown as points and as a thin line connecting items ordered by difficulty.}
  \item{show_smoothed}{Logical scalar. If \code{TRUE}, the non-monotonized moving average is shown as a thin dashed blue line.}
  \item{show_residuals}{Logical scalar. If \code{TRUE}, an additional residual panel is shown for each rater. Residuals are computed as raw rating minus smoothed moving average.}
  \item{show_aggregate}{Logical scalar. If \code{TRUE}, an additional aggregate panel is shown. It overlays the monotonized rater curves in rater-specific colors and draws the mean cut scores from \code{res_list$cuts_summary}.}
  \item{show_aggregate_labels}{Logical scalar. If \code{TRUE}, rater names are shown near the right-hand end of the monotonized curves in the aggregate panel. Only used when \code{show_aggregate = TRUE}.}
}
\details{
One main idea of the IDM method is to account for rater noise by smoothing and monotonizing the relationship between item difficulty and the assigned levels. If \code{show_raw = TRUE}, grey points and a thin grey line show the original rater assignments after ordering items by difficulty. If \code{show_smoothed = TRUE}, a thin dashed blue line shows the moving average before monotonization. The red line represents the monotonized isotonic curve used to find the vertical intercepts. If the smoothed curve is already non-decreasing, the blue dashed line lies directly on top of the red line. Vertical cut lines are drawn at the cut scores stored by \code{computeCutsIDM()}, which are linearly interpolated boundary crossings of the monotonized curve.

Technically, the plot is constructed from \code{res_list$plot_data}. For each rater facet, the x-axis is the item difficulty column stored as \code{est}; the y-values are the raw rating stage \code{stage_raw}, the smoothed moving average \code{stage_sm}, and the monotonized isotonic fit \code{stage_iso}. Horizontal lines are drawn at \code{res_list$boundaries}. Vertical lines are drawn at the difficulty-scale cuts in \code{res_list$cuts_per_person}; therefore the plotted cut positions are on the same x-axis scale as the item difficulties. Interpolated item positions, if needed for tabular summaries, are stored separately in \code{res_list$cut_positions_per_person}.

With \code{show_aggregate = TRUE}, the plot adds an aggregate panel labelled \code{Mean}. This panel overlays the monotonized rater curves from the individual panels as thin colored lines and draws vertical lines at the mean difficulty-scale cuts in \code{res_list$cuts_summary}. With \code{show_aggregate_labels = TRUE}, the colored curves are labelled by rater name near their right-hand end. Label positions are adjusted vertically when several rater curves end at similar values. These mean cuts correspond to the cut scores reported by \code{summary(res_list)}. The legend is reserved for cut score labels; aggregate rater colors are not added to the legend.

With \code{show_residuals = TRUE}, the plot uses an additional row of facets. The residual in item \eqn{i} is \eqn{e_i = r_i - z_i}, where \eqn{r_i} is the raw rating and \eqn{z_i} is the smoothed moving average. Residuals are drawn as vertical segments from zero to \eqn{e_i}. The cut lines are repeated in the residual panel so that large local deviations can be inspected relative to the final cut locations.

If \code{computeCutsIDM()} stored ordinal rating labels in \code{res_list}, these labels are used on the y-axis.
}
\value{
A \code{ggplot2} object.
}
\examples{
dat <- data.frame(
  est = seq(100, 800, by = 100),
  Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5),
  Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5)
)

res <- computeCutsIDM(dat, boundaries = c(1.5, 2.5, 3.5))
plotCutsIDM(res)

## The plotted vertical lines correspond to these difficulty-scale cuts:
res$cuts_per_person

## Hide the auxiliary raw and smoothed functions:
plotCutsIDM(res, show_raw = FALSE, show_smoothed = FALSE)

## Add an aggregate panel with all monotonized curves and mean cuts:
plotCutsIDM(res, show_aggregate = TRUE)

## Hide rater labels in the aggregate panel:
plotCutsIDM(res, show_aggregate = TRUE, show_aggregate_labels = FALSE)

## Add residual panels:
plotCutsIDM(res, show_residuals = TRUE)
}
