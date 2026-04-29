\name{plotCutsIDM}
\alias{plotCutsIDM}
\title{Plot Raw Values, Moving Average, and Monotonized Moving Average}
\description{
Visualizes the IDM rating process for each rater, showing raw ratings, smoothed moving averages, and the final isotonic regression line used to determine cut scores.
}
\usage{
plotCutsIDM(res_list)
}
\arguments{
  \item{res_list}{A list returned by \code{computeCutsIDM()} containing the processed data and cut score coordinates.}
}
\details{
One main idea of the IDM method is to account for rater noise by smoothing and monotonizing the relationship between item difficulty and the assigned levels. Blue lines represent the moving average, while red lines represent the monotonized curve used to find the vertical intercepts.
}
\value{
A \code{ggplot2} object.
}
\author{Karoline Sachse}
\examples{
# res <- computeCutsIDM(my_data)
# plotCutsIDM(res)
}
