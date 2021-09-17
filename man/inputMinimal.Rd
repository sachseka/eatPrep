\name{inputMinimal}
\alias{inputMinimal}
\docType{data}
\title{Data Frames with Code, Subunit and Unit Information for Datasets in \code{\link{inputDat}}
}
\description{
These data frames contain information about codes, subunits and units for the
datasets in \code{\link{inputDat}} and are necessary inputs for e.g.
\code{\link{automateDataPreparation}}, \code{\link{checkData}},
\code{\link{recodeData}}, \code{\link{aggregateData}} and \code{\link{scoreData}}.
}
\usage{data(inputList)}
\format{
A list with several data frames:
\enumerate{

    \item units: Unit information, contains the following columns:


    \describe{
      \item{unit}{Unit name.}
      \item{unitAggregateRule}{Aggregate rule for unit:
        \code{SUM}; \code{MEAN}.}
    }

  \item subunits: Subunit information, contains the following columns:

	\describe{
      \item{unit}{Unit name, for which subunits are given.}
      \item{subunit}{Subunit name.}
      \item{subunitRecoded}{Name of recoded subunit.}
    }


	  \item values: Value information, contains the following columns:
	\describe{
	  \item{subunit}{Subunit name, for which values are given.}
	  \item{value}{Valid values for the respective subunit.}
	  \item{valueRecode}{Recode values for the respective value.}
	  \item{valueType}{Value types:
		\code{vc} = valid code;
		\code{mbd} = missing -- by design;
		\code{mvi} = missing -- volume insufficient;
		\code{mnr} = missing -- not reached;
		\code{mci} = missing -- coding impossible;
		\code{mbi} = missing -- by intention.
	  }
	}

    \item unitRecodings: Unit recoding information, contains the following columns:

	\describe{
      \item{unit}{Unit name}
      \item{value}{Valid values for the respective unit.}
      \item{valueRecode}{Recode values for the respective value.}
 	    \item{valueType}{Value types:
		  \code{vc} = valid code;
		  \code{mbd} = missing -- by design;
		  \code{mvi} = missing -- volume insufficient;
		  \code{mnr} = missing -- not reached;
		  \code{mci} = missing -- coding impossible;
		  \code{mbi} = missing -- by intention.
	    }
    }

 \item blocks: missing aggregation pattern for \code{\link{aggregateData}}
\describe{
      \item{subunit}{Subunit name.}
      \item{block}{Block name.}
      \item{subunitBlockPosition}{The subunit's position in the corresponding block.}
}

 \item booklets: Design
\describe{
      \item{booklet}{Booklet name.}
      \item{block1 ... blockX}{Block names in booklet.}
}
 \item rotation: Assignment of IDs to booklets
\describe{
      \item{ID}{Case identifier.}
      \item{booklet}{Booklet name.}
}

}
}
%\details{

%}
%\source{
%%  ~~ reference to a publication or URL from which the data were obtained ~~
%}
%\references{
%%  ~~ possibly secondary sources and usages ~~
%}
\examples{
data(inputMinimal)
str(inputMinimal)
}
\keyword{datasets}
