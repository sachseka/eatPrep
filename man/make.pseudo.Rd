\name{make.pseudo}
\alias{make.pseudo}
\title{Transform ratings from real raters into pseudo ratings}
\description{Data from large-scale assessments often are rated by
multiple raters. This function reduces the number of raters by the use
of ``pseudo raters''.}
\usage{
make.pseudo(datLong, idCol, varCol, codCol, alwaysPrefer = NULL,
            alwaysNeglect = NULL, valueCol, n.pseudo, item.groups = NULL,
            randomize.order = TRUE, verbose = FALSE)
}
\arguments{
  \item{datLong}{
Data set in the longformat, i.e. one row per examinee-variable-rater combination.
}
  \item{idCol}{
Name or column number of the person identifier (ID) variable.
}
  \item{varCol}{
Name or column number of the variable identifier.
}
  \item{codCol}{
Name or column number of the rater identifier variable.
}
  \item{alwaysPrefer}{
Optional: Single name of the rater that should always be preferred if it is part of a double coding.
}
  \item{alwaysNeglect}{
Optional: Single name of the rater that should always be neglected if it is part of a double coding.
This means that coding by this rater is only taken into account if no other rater has rated this response.
}
  \item{valueCol}{
Name or column number of the value variable.
}
  \item{n.pseudo}{
How many pseudo raters should be used? (value must be lower than the number of real raters)
}
  \item{item.groups}{
Optional: List of linked variables that could later be aggregated into items. If two raters
make inconsistent judgments, it may be more favorable for aggregation if all variables
belonging to an item are coded by the same rater per examinee. However, if a rater has not
rated all the variables of the item, the ratings of other raters are used for the variables
not rated by this rater.
}
  \item{randomize.order}{
Logical: if TRUE, the selection of raters to pseudo raters is random.
}
  \item{verbose}{
Logical: give information about number of persons, variables, raters?
}
}
\value{
A data.frame in the long format.
}
\author{
Sebastian Weirich
}
\examples{
data(rater)
oneRater <- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            valueCol="value", n.pseudo=1, verbose=TRUE)
twoRaters<- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            valueCol="value", n.pseudo=2)
# with item groups, allowing that all variables belonging to an item are coded by the
# same rater (per examinee)
itemGroup<- list(first = c("V01", "V03"), second = c("V05", "V06", "V07"))
oneRater2<- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            item.groups = itemGroup, valueCol="value", verbose=TRUE, n.pseudo=1)
attr(oneRater2, "info")
# prefer John
oneRater <- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            alwaysPrefer = "John", valueCol="value", n.pseudo=1, verbose=TRUE)
# neglect Edward
oneRater <- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            alwaysNeglect = "Edward", valueCol="value", n.pseudo=1, verbose=TRUE)
# prefer Dolores and neglect Edward
oneRater <- make.pseudo (datLong=rater, idCol="id", varCol="variable", codCol="rater",
            alwaysPrefer = "Dolores", alwaysNeglect = "Edward", valueCol="value",
            n.pseudo=1, verbose=TRUE)
}
