\name{plotCutsIDM}
\alias{plotCutsIDM}
\title{Plot Raw Values, Moving Average, and Monotonized Moving Average}
\description{
Visualizes the IDM rating process for each rater, showing raw ratings, smoothed moving averages, and the final isotonic regression line used to determine cut scores.
}
\usage{
plotCutsIDM(res_list, est_col = NULL)
}
\arguments{
  \item{res_list}{A list returned by \code{computeCutsIDM()} containing the processed data and cut score coordinates.}
  \item{est_col}{Optional character scalar. Label to use for the item difficulty axis. If \code{NULL}, the value stored by \code{computeCutsIDM()} is used.}
}
\details{
One main idea of the IDM method is to account for rater noise by smoothing and monotonizing the relationship between item difficulty and the assigned levels. Blue lines represent the moving average, while red lines represent the monotonized curve used to find the vertical intercepts. Vertical cut lines are drawn at the cut scores stored by \code{computeCutsIDM()}, which are linearly interpolated boundary crossings of the monotonized curve.

Technically, the plot is constructed from \code{res_list$plot_data}. For each rater facet, the x-axis is the item difficulty column stored as \code{est}; the y-values are the raw rating stage \code{stage_raw}, the smoothed moving average \code{stage_sm}, and the monotonized isotonic fit \code{stage_iso}. Horizontal lines are drawn at \code{res_list$boundaries}. Vertical lines are drawn at the difficulty-scale cuts in \code{res_list$cuts_per_person}; therefore the plotted cut positions are on the same x-axis scale as the item difficulties. Interpolated item positions, if needed for tabular summaries, are stored separately in \code{res_list$cut_positions_per_person}.

If \code{computeCutsIDM()} stored ordinal rating labels in \code{res_list}, these labels are used on the y-axis.
}
\value{
A \code{ggplot2} object.
}
\author{Karoline Sachse}
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
}
