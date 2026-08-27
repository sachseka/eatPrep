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
  \item{boundaries}{Numeric vector. The cut boundaries on the internal ordinal rating scale. For example, \code{c(1.5, 2.5, 3.5)} calculates cuts between four adjacent performance levels.}
  \item{est_col}{Character scalar. Name of the column containing item difficulty estimates. Defaults to \code{"est"}.}
  \item{rater_cols}{Character vector. Names of the rater rating columns for wide-format input. If \code{NULL}, rater columns are selected with \code{rater_pattern}.}
  \item{rater_pattern}{Character scalar. Pattern used to find rater rating columns when \code{rater_cols = NULL} in wide-format input. Defaults to \code{"Rater"}.}
  \item{rater_id_col}{Character scalar. Name of the rater identifier column for long-format input. Rater identifiers may be names or IDs.}
  \item{rating_col}{Character scalar. Name of the rating column for long-format input. Values may be numeric or ordinal labels when \code{rating_levels} is supplied.}
  \item{input_format}{Character scalar. One of \code{"auto"}, \code{"long"}, or \code{"wide"}. In \code{"auto"} mode, the function uses long format when both \code{rater_id_col} and \code{rating_col} are supplied, otherwise wide format.}
  \item{rating_levels}{Optional atomic vector defining the ordered rating scale, for example \code{c("1a", "1b", "2", "3", "4")}. Non-numeric ratings require this argument. If \code{boundaries} is not supplied, adjacent boundaries are derived from these levels.}
  \item{missing}{Character scalar. \code{"drop"} excludes missing ratings from smoothing, isotonic regression, and cut computation. \code{"smooth"} keeps legacy-like smoothing with \code{na.rm = TRUE}. \code{"error"} rejects missing ratings.}
  \item{cut_labels}{Optional character vector with one label per boundary. Labels must be unique and start with \code{"cut"} so that \code{plotCutsIDM()} remains compatible.}
}
\details{
The function supports two input formats. In long format, each row contains one item-rater combination and the columns identified by \code{est_col}, \code{rater_id_col}, and \code{rating_col}. In wide format, each row contains one item and one or more rater rating columns. Wide-format input keeps the previous default behavior.

All input is normalized internally to a long representation with item difficulty, rater identifier, and numeric rating stage. If ratings are supplied as labels, \code{rating_levels} defines their ordinal order and the labels are mapped to \code{1, 2, ..., k} for computation.

The smoothing padding and plot scale are based on the observed rating scale and the supplied boundaries. Missing ratings are handled according to \code{missing}. The default \code{"drop"} is conservative: missing ratings do not create smoothed values. The \code{"smooth"} option uses the legacy-like moving average behavior where missing values inside the smoothing window are ignored.

The function processes each rater by:
\enumerate{
  \item Sorting items by difficulty (\code{est_col}).
  \item Applying a symmetric moving average (order = 1) with boundary padding at the minimum and maximum rating stage.
  \item Applying isotonic regression (\code{isoreg}) to ensure the mapping of difficulty to level is non-decreasing.
  \item Computing the cut score as the linearly interpolated item difficulty where the monotonized function crosses the specified boundary.
}

Cut score columns start with \code{cut}. Canonical numeric boundaries such as \code{1.5} and \code{2.5} are labelled as \code{cut12} and \code{cut23} for numeric ratings. With ordinal labels, labels such as \code{cut_1a_1b} are used. Non-canonical boundaries include the boundary value, for example \code{cut_1a_1b_bound1_3}.

In addition to the difficulty-scale cut scores, the function stores the corresponding interpolated item positions in \code{cut_positions_per_person}. \code{cut_statistics} reports mean, standard deviation, and standard error for both item positions (\code{page_*}) and difficulty cuts (\code{diff_*}). \code{level_statistics} summarizes the item difficulty intervals implied by the mean cuts, including item counts and item difficulty means and standard deviations per level.
}
\value{
A list containing \code{cuts_per_person}, \code{cut_positions_per_person}, \code{cuts_summary}, \code{cut_statistics}, \code{level_statistics}, \code{plot_data}, \code{boundaries}, \code{cut_labels}, \code{min_val}, \code{max_val}, \code{est_col}, \code{rater_cols}, and additional metadata used by \code{plotCutsIDM()}.
}
\author{Karoline Sachse}
