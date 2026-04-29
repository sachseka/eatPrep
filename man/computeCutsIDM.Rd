\name{computeCutsIDM}
\alias{computeCutsIDM}
\title{Compute Cut Scores based on Rater's Monotonized Moving Averages}
\description{
Calculates an arbitrary number of cut scores for Item Descriptor Matching (IDM). The number of cuts is determined by the length of the \code{boundaries} argument.
}
\usage{
computeCutsIDM(dat, boundaries = c(1.5, 2.5, 3.5, 4.5))
}
\arguments{
  \item{dat}{A data frame containing column \code{est} and rater columns containing "Rater" in their name.}
  \item{boundaries}{Numeric vector. The number of cut scores to calculate. For example, \code{c(1.5, 2.5, 3.5)} will calculate 3 cuts at the specified steps for 4 performance levels.}
}
\details{
The function dynamically adjusts the smoothing padding and plot scales based on the length of \code{boundaries}. If the length of the boundaries vector is k, the function assumes there are k + 1 performance levels.

The function processes each rater column by:
\enumerate{
  \item Sorting items by difficulty (\code{est}).
  \item Applying a symmetric moving average (order = 1) with boundary padding (1 at the start, k+1 at the end).
  \item Applying isotonic regression (\code{isoreg}) to ensure the mapping of difficulty to level is non-decreasing.
  \item Computing the cut score as the item difficulty (\code{est}) where the monotonized function first reaches or exceeds the specified boundary.
}
}
\value{
A list containing \code{cuts_per_person}, \code{cuts_summary}, \code{plot_data}, \code{boundaries}, and \code{max_val}.
}
\author{Karoline Sachse}
