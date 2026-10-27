\name{computeCutsIDMOrdinal}
\alias{computeCutsIDMOrdinal}
\title{Compute IDM Cuts from a Cumulative Ordinal Model}
\description{
Estimates all performance-level boundaries jointly with a cumulative-logit
model. By default, crossed random intercepts account for systematic
differences between raters and between items. The main cuts describe a
reference rater and item whose random intercepts are zero. Input columns
follow the conventions of \code{\link{computeCutsIDMMAPT}}.
}
\usage{
computeCutsIDMOrdinal(
  dat,
  boundaries = c(1.5, 2.5, 3.5, 4.5),
  est_col = "est",
  item_id_col = NULL,
  rater_cols = NULL,
  rater_pattern = "Rater",
  rater_id_col = NULL,
  rating_col = NULL,
  input_format = c("auto", "long", "wide"),
  rating_levels = NULL,
  missing = c("drop", "error"),
  cut_labels = NULL,
  per_rater = TRUE,
  random_effects = c("rater", "item"),
  control = list()
)
}
\arguments{
\item{dat}{A data frame containing item difficulties and ordered ratings.
Each item--rater pair must occur at most once, and an item must have the
same difficulty wherever it occurs.}
\item{boundaries}{Strictly increasing half-integers selecting adjacent
rating levels, for example \code{c(1.5, 2.5)} for three levels. These are
indices on the rating scale, not item difficulties. When omitted together
with explicit \code{rating_levels}, all adjacent boundaries are returned.
With the category definition held fixed, selecting fewer boundaries changes
only the returned cuts. See \code{rating_levels} for how boundaries also
enter the category definition when labels are not supplied.}
\item{est_col}{Name of the finite, nonmissing numeric item-difficulty
column. The returned cuts use this same scale.}
\item{item_id_col}{Name of the item identifier column. Required for long
input. With wide input, rows identify items when this argument is omitted.}
\item{rater_cols}{Names of the rating columns in wide input. If
\code{NULL}, they are selected by \code{rater_pattern}.}
\item{rater_pattern}{Regular expression identifying wide rating columns.}
\item{rater_id_col}{Name of the rater identifier column in long input.}
\item{rating_col}{Name of the rating column in long input.}
\item{input_format}{\code{"long"} requires item, rater, and rating
columns. \code{"wide"} uses one row per item and one column per rater.
\code{"auto"} infers the layout from the supplied column arguments.}
\item{rating_levels}{Optional unique rating labels ordered from lowest
to highest performance level, for example \code{c("1a", "1b", "2", "3")}
or \code{c("basic", "proficient", "advanced")}. Their positions become
indices \code{1, ..., K}. Without this argument, ratings must be positive
integer level codes, and the declared levels are \code{1, ..., K}, where
\code{K} is the largest observed code or \code{ceiling(boundaries)},
whichever is greater. The default boundaries therefore declare at least
five levels. Supply \code{rating_levels} to fix the category definition
independently of the requested output boundaries.}
\item{missing}{\code{"drop"} removes missing ratings while keeping
other available ratings of the same item or rater. \code{"error"} rejects
missing ratings. Missing identifiers and difficulties are always rejected.}
\item{cut_labels}{Optional unique, nonempty names for the requested cuts.
Defaults to names such as \code{cut12}, or \code{cut_basic_proficient}
with explicit category labels. The name \code{"person"} is reserved.}
\item{per_rater}{Also return conditional rater cuts? Defaults to
\code{TRUE}. They use the rater effects estimated in the same joint model;
no separate rater models are fitted. This argument does not change the
reference cuts or the estimated model.}
\item{random_effects}{Character vector selecting random intercepts:
\code{c("rater", "item")} (default), \code{"rater"}, \code{"item"},
or \code{character()} for a model without random effects. Selected grouping
factors must have enough observed groups and replication to fit their
effects. The function does not silently remove a requested effect.}
\item{control}{Named list of supported optimization controls. Both model
types accept \code{trace}, \code{maxIter}, \code{gradTol}, and
\code{maxLineIter}. Mixed models additionally accept \code{innerCtrl},
\code{useMatrix}, \code{checkRanef}, and the \code{nlminb} controls
\code{iter.max}, \code{eval.max}, \code{rel.tol}, \code{abs.tol},
\code{x.tol}, \code{xf.tol}, \code{step.min}, \code{step.max},
\code{sing.tol}, and \code{diff.g}. Models without random effects also
accept \code{relTol}, \code{tol}, \code{maxModIter}, and
\code{convergence}. See \code{\link[ordinal]{clmm.control}},
\code{\link[ordinal]{clm.control}}, and \code{\link[stats]{nlminb}}.
The optimizer is fixed to \code{nlminb} for mixed models and Newton for
models without random effects; unsupported controls cause an error.
Mixed-model defaults include \code{useMatrix = TRUE},
\code{maxIter = 100}, \code{innerCtrl = "giveError"},
\code{iter.max = 200}, \code{eval.max = 400}, and
\code{rel.tol = 1e-10}.}
}
\details{
\subsection{Methodological basis and scope}{
This function applies an established ordinal modelling framework to IDM
ratings. Christensen's (2026) cumulative-link mixed-model tutorial gives the
cumulative-logit model with normally distributed judge effects, and the
\code{ordinal} documentation supports crossed random effects. Taylor et al.
(2023), especially their Simulation 2, motivate modelling ordinal item
ratings with both participant and item effects. Their application concerns
rating norms and uses a probit link; this function uses a logit link. Their
study does not address IDM standard setting.

For IDM itself, Ferrara et al. (2008, p. 12) describe logistic regression
as one way of locating cuts in transition regions. Sireci et al. (2006,
pp. 54--55) derive MAPT cuts from separate binary regressions at probability
0.5. The present function combines the ordinal mixed-model framework with
this probability-crossing definition, estimating all boundaries jointly.
The cited works support these ingredients; they do not establish this
particular combination as a validated or superior IDM cut-score method.
The formulas below specify the package's extension explicitly.
}
\subsection{1. Ordered ratings and the difficulty scale}{
Let \eqn{i} index items, \eqn{r} raters, and
\eqn{R_{ir}\in\{1,\ldots,K\}} the ordered rating assigned to an item.
The response is a rating category, not whether a student answers correctly.
With \code{rating_levels = c("basic", "proficient", "advanced")}, the
indices are 1, 2, and 3. A requested boundary \eqn{b_k=k+0.5} separates
categories at or below \eqn{k} from those above \eqn{k}; for example,
\code{boundaries = 1.5} separates \code{basic} from the higher categories.
These boundary indices differ from both fitted model thresholds and cuts
on the item-difficulty scale.

Write \eqn{\mathcal O} for the set of retained item--rater pairs and
\eqn{N=|\mathcal O|} for the number of observed ratings. Each item has
one supplied difficulty \eqn{x_i}. For numerical stability, the function
uses standardized difficulties
\deqn{
\mu=\frac{1}{N}\sum_{(i,r)\in\mathcal O}x_i,\qquad
s=\sqrt{\frac{1}{N-1}\sum_{(i,r)\in\mathcal O}(x_i-\mu)^2},\qquad
z_i=\frac{x_i-\mu}{s}.
}{
mu = sum(x_i over observed item-rater pairs) / N;
s = sqrt(sum((x_i - mu)^2 over those pairs) / (N - 1));
z_i = (x_i - mu) / s.
}
An item's difficulty enters these summaries once per observed rating.
Thus items with more ratings contribute more entries when the design is
unbalanced. Returned cuts are transformed back to the original scale.
}
\subsection{2. Cumulative probabilities and proportional odds}{
Define the logistic distribution function
\eqn{\Lambda(t)=1/(1+\exp(-t))} and the linear predictor
\eqn{\eta_{ir}=\beta z_i+u_r+v_i}. The model is
\deqn{
\Pr(R_{ir}\leq k\mid x_i,u_r,v_i)=\Lambda(\alpha_k-\eta_{ir}),
\qquad k=1,\ldots,K-1.
}{
P(R_ir <= k | x_i, u_r, v_i) = logistic(alpha_k - beta*z_i - u_r - v_i).
}
Equivalently, since \eqn{\operatorname{logit}(p)=\log(p/(1-p))},
\deqn{
\operatorname{logit}\Pr(R_{ir}\leq k\mid x_i,u_r,v_i)
=\alpha_k-\beta z_i-u_r-v_i.
}{
logit P(R_ir <= k | x_i, u_r, v_i) = alpha_k - beta*z_i - u_r - v_i.
}
Here \eqn{\alpha_1<\cdots<\alpha_{K-1}} are freely estimated
thresholds on the latent logit scale, \eqn{\beta} is the common difficulty
slope, and \eqn{u_r} and \eqn{v_i} are rater and item random intercepts.
There is no separate fixed intercept: its location is absorbed into the
thresholds. Their spacings are not constrained to be equal.

The upper-category probability used for the cuts is
\deqn{
p_k(x_i,u_r,v_i)=\Pr(R_{ir}>k\mid x_i,u_r,v_i)
=\Lambda(\beta z_i+u_r+v_i-\alpha_k).
}{
p_k(x_i, u_r, v_i) = P(R_ir > k | x_i, u_r, v_i)
= logistic(beta*z_i + u_r + v_i - alpha_k).
}
The same \eqn{\beta} applies to every boundary. Holding the random
effects fixed, an increase of \eqn{\Delta x} in difficulty multiplies
the odds of a rating above \emph{any} boundary by
\eqn{\exp(\beta\Delta x/s)}. This is the proportional-odds assumption.
A positive slope makes these probabilities increase with difficulty.
}
\subsection{3. Category probabilities, random effects, and estimation}{
The model uses the full ordered response in one likelihood. Define
\eqn{\alpha_0=-\infty} and \eqn{\alpha_K=+\infty}. The probability
of a particular category \eqn{j} is the difference between two cumulative
probabilities:
\deqn{
\pi_{irj}=\Pr(R_{ir}=j\mid x_i,u_r,v_i)
=\Lambda(\alpha_j-\eta_{ir})-\Lambda(\alpha_{j-1}-\eta_{ir}),
\qquad j=1,\ldots,K.
}{
pi_irj = P(R_ir = j | x_i, u_r, v_i)
= logistic(alpha_j - eta_ir) - logistic(alpha_(j-1) - eta_ir).
}
These probabilities are nonnegative and sum to one. For a fixed category
definition, changing which boundaries are requested for output does not
change the categories used in the fit or create separate regressions.

The random intercepts satisfy
\deqn{
u_r\sim N(0,\sigma_u^2),\qquad v_i\sim N(0,\sigma_v^2).
}{
u_r ~ Normal(0, sigma_u^2); v_i ~ Normal(0, sigma_v^2).
}
They are mutually independent and independent of the supplied difficulty
predictor. Ratings are assumed conditionally independent given these
effects. Sharing a rater or an item nevertheless induces dependence after
the effects are integrated out. The effects are crossed when raters assess
multiple items and items are assessed by multiple raters.

Let \eqn{\phi_{\sigma}} denote a mean-zero normal density with standard
deviation \eqn{\sigma}. For positive variance components, the marginal
likelihood is
\deqn{
L(\boldsymbol{\alpha},\beta,\sigma_u,\sigma_v)
=\int\!\int
\left[\prod_{(i,r)\in\mathcal O}\pi_{ir,R_{ir}}\right]
\left[\prod_r\phi_{\sigma_u}(u_r)\right]
\left[\prod_i\phi_{\sigma_v}(v_i)\right]
\,d\boldsymbol{u}\,d\boldsymbol{v}.
}{
L = integral over all rater and item effects of
  product(observed-category probabilities) *
  product(normal rater-effect densities) * product(normal item-effect densities).
}
The integration is over all observed rater and item effects, not separately
over each rating. The thresholds, common slope, and variance components
are estimated jointly by approximate maximum likelihood using
\code{\link[ordinal]{clmm}} with \code{link = "logit"}, flexible
thresholds, and the Laplace approximation (\code{nAGQ = 1}). Omitted
effects are fixed to zero and their integrals disappear. A zero variance
component is interpreted as a degenerate distribution at zero. With no
random effects, \code{\link[ordinal]{clm}} maximizes the ordinary ordinal
likelihood.

The returned random-effect estimates are conditional modes given the
fitted model parameters. For positive fitted variances they maximize,
up to constants,
\deqn{
\sum_{(i,r)\in\mathcal O}\log\pi_{ir,R_{ir}}
-\frac{1}{2\widehat\sigma_u^2}\sum_r u_r^2
-\frac{1}{2\widehat\sigma_v^2}\sum_i v_i^2.
}{
sum(log observed-category probabilities)
- sum(u_r^2)/(2*estimated_rater_variance)
- sum(v_i^2)/(2*estimated_item_variance).
}
The normal-distribution terms shrink the effects towards zero. A positive
rater effect means a tendency to assign higher levels at the same
difficulty; a positive item effect means higher ratings for that item than
its supplied difficulty alone predicts. Item effects describe residual
variation in ratings, not measurement error or recalibration of
\code{est}. Ratings are not smoothed or automatically trimmed.
}
\subsection{4. Deriving reference cuts at probability 0.5}{
Use hats to denote estimated model parameters. The reference probability
curve fixes both random intercepts to zero:
\deqn{
\widehat p_k(x,0,0)
=\Lambda\left(\widehat\beta\frac{x-\mu}{s}-\widehat\alpha_k\right).
}{
estimated_p_k(x, 0, 0) = logistic(estimated_beta*(x-mu)/s - estimated_alpha_k).
}
A reference cut \eqn{\widehat c_k} satisfies
\eqn{\widehat p_k(\widehat c_k,0,0)=0.5}. Because
\eqn{\operatorname{logit}(0.5)=0},
\deqn{
\widehat\beta\frac{\widehat c_k-\mu}{s}-\widehat\alpha_k=0
\quad\Longrightarrow\quad
\widehat c_k=\mu+s\frac{\widehat\alpha_k}{\widehat\beta}.
}{
estimated_beta*(reference_cut_k-mu)/s - estimated_alpha_k = 0;
reference_cut_k = mu + s*estimated_alpha_k/estimated_beta.
}
These values appear in \code{cuts_summary}. They are difficulties, whereas
\eqn{\widehat\alpha_k} is a threshold on the model's latent scale.
The 0.5 criterion concerns a \emph{rating-level assignment}; it is neither
a student's probability of answering correctly nor the proportion of the
student population above a cut. It also does not by itself establish a
classification rule with optimal educational consequences.

With \eqn{s>0}, \eqn{\widehat\beta>0}, and ordered thresholds,
\deqn{
\widehat c_{k+1}-\widehat c_k
=\frac{s}{\widehat\beta}(\widehat\alpha_{k+1}-\widehat\alpha_k)>0.
}{
reference_cut_(k+1) - reference_cut_k
= s*(estimated_alpha_(k+1)-estimated_alpha_k)/estimated_beta > 0.
}
Thus the joint model supplies ordered cuts without sorting the estimated
values after fitting.
}
\subsection{5. Conditional rater cuts and the plotted curves}{
For rater \eqn{r}, retain the estimated conditional mode
\eqn{\widehat u_r} and set the item effect to zero. Solving
\eqn{\widehat p_k(x,\widehat u_r,0)=0.5} gives
\deqn{
\widehat c_{rk}
=\mu+s\frac{\widehat\alpha_k-\widehat u_r}{\widehat\beta}
=\widehat c_k-\frac{s\widehat u_r}{\widehat\beta}.
}{
rater_cut_rk = mu + s*(estimated_alpha_k-estimated_rater_effect_r)/estimated_beta
= reference_cut_k - s*estimated_rater_effect_r/estimated_beta.
}
These are \code{cuts_per_person}. A positive rater effect shifts all of
that rater's cuts down by the same amount; random slopes or rater-specific
threshold spacings are not fitted. The estimates come from one shared
model, not independent rater fits. With no rater effect, observed raters
share the reference cuts. Raters without retained ratings have no
individual cut.

For \eqn{u^*=0} in the reference panel, or
\eqn{u^*=\widehat u_r} in a rater panel, the displayed curve can also
be written on the original difficulty scale as
\deqn{
\widehat p_k(x,u^*,0)=\Lambda(A_k+B x),\qquad
A_k=u^*-\widehat\alpha_k-\widehat\beta\mu/s,\qquad
B=\widehat\beta/s.
}{
estimated_p_k(x, u_star, 0) = logistic(A_k + B*x);
A_k = u_star - estimated_alpha_k - estimated_beta*mu/s;
B = estimated_beta/s.
}
The diagnostic columns \code{intercept} and \code{slope} contain
\eqn{A_k} and \eqn{B}; equivalently the curve is
\eqn{\Lambda(B(x-\widehat c))}. Item effects are estimated and returned,
but held at zero in all reported cuts and plotted curves.

The reference cuts are not obtained by averaging the fitted rater cuts.
Nor is the reference probability curve a marginal curve averaged over
raters and items. Under the assumed symmetric, mean-zero random-effect
distributions, the model-population marginal curve does share its 0.5
crossing with the reference curve: at that point the logistic argument
is \eqn{u+v}, and \eqn{\Lambda(t)+\Lambda(-t)=1}. Their shapes still
differ when the random-effect variance is positive. This identity does
not require an empirical, possibly unbalanced average of the observed
raters and items to have the same crossing.
}
\subsection{6. Worked numerical example}{
Suppose difficulties were standardized with \eqn{\mu=500}, \eqn{s=100},
and the fitted four-category model has
\eqn{\widehat\beta=2} and
\eqn{(\widehat\alpha_1,\widehat\alpha_2,\widehat\alpha_3)=(-1,0,1)}.
For boundaries 1.5, 2.5, and 3.5, the reference cuts are
\deqn{
500+100\frac{(-1,0,1)}{2}=(450,500,550).
}{
500 + 100*c(-1,0,1)/2 = c(450,500,550).
}
For a rater with \eqn{\widehat u_r=0.4}, the cuts shift by
\eqn{-100\times0.4/2=-20}, giving \eqn{(430,480,530)}. For the middle
boundary, the rater's upper-category logit at difficulty 480 is
\eqn{2(480-500)/100+0.4-0=0}, so its probability is exactly 0.5.
The corresponding reference probability is 0.5 at difficulty 500.
These numbers illustrate the calculation; they are not empirical results.
}
\subsection{Fit diagnostics and unavailable cuts}{
Inspect \code{model_diagnostics} and \code{cut_diagnostics} before using
the cuts. The common difficulty slope must be positive and numerically
nonzero. A failed, nonconverged, or otherwise unusable model yields
\code{NA} cuts and an explanatory diagnostic status, with the original
rating data retained. Invalid input instead produces an error.

Every declared category must occur in the retained ratings. With at least
two observed categories, an unobserved declared category gives
\code{missing_categories} diagnostics and unavailable cuts;
the function does not silently join categories and relabel the remaining
thresholds. For a fixed category definition, requesting only a subset of
boundaries does not remove this requirement because the same joint ordinal
model is still fitted.
The statuses are:
\describe{
\item{\code{ok}}{A usable fit and positive common slope supply cuts.}
\item{\code{one_class}}{Fewer than two categories occur in the retained ratings.}
\item{\code{missing_categories}}{Some declared categories are unobserved.}
\item{\code{constant_est}}{All retained item difficulties are identical.}
\item{\code{separation}}{The difficulty ranges of successive categories
are completely ordered without overlap, allowing an infinite increasing slope.}
\item{\code{nonpositive_slope}}{The common slope is nonpositive or numerically flat.}
\item{\code{non_convergence}}{The optimizer or subsequent gradient checks
do not establish convergence.}
\item{\code{ill_conditioned}}{Hessian checks do not establish adequate
curvature for the estimated parameters.}
\item{\code{unordered_thresholds}}{Estimated thresholds are not strictly ordered.}
\item{\code{fit_error}, \code{non_finite}}{Estimation failed or returned
unusable numerical values; inspect the stored warning.}
\item{\code{no_data}}{An individual rater has no retained ratings.}
}

The numerical diagnostics include convergence information, raw and
Hessian-scaled maximum absolute gradients, Hessian information, and a flag
for random-effect standard deviations below \eqn{10^{-4}}. A near-zero variance may indicate that the data
support little residual variation for that grouping factor; it does not
by itself invalidate otherwise usable cuts. A usable model does not
establish that the proportional-odds or random-effect assumptions hold.
When a variance lies at its zero boundary and the stored Hessian is
ill-conditioned, the function checks the Hessian and gradient after
removing only the variance dimensions whose standard deviations are
below \eqn{10^{-4}}. Fixed parameters and other variance dimensions remain
in this check. The original stored-Hessian diagnostic remains available;
\code{ordinal} may itself have already removed boundary dimensions.

Cuts outside the observed difficulty range are retained and marked
\code{extrapolated = TRUE}. Reference cuts use the overall observed
range; individual diagnostics use the corresponding rater's observed
range. With a usable positive slope and ordered thresholds, the requested
cuts are ordered. The function does not rearrange estimates to hide a
failed fit.
}
\subsection{Plotting and interpretation}{
\code{plotCutsIDM(result, show_aggregate = TRUE)} shows conditional rater
curves and the \code{Reference (ordinal)} panel. Curves show
\eqn{\Pr(R>k\mid x)} with the item effect fixed to zero; the reference
panel also sets the rater effect to zero. With \code{per_rater = FALSE},
only the reference panel is shown. Plotting uses the stored fit results
and does not estimate new models.

Raw points show observed proportions above each boundary. Optional
residuals are the differences between these proportions and the displayed
curves. Because the displayed curves set item effects to zero, these are
reference-curve discrepancies rather than residuals from the fully
conditional model.

\code{\link{plotPopulationCutsIDM}} accepts the result directly. Its
legacy \code{cut_selection = "mean"} option selects reference cuts;
\code{"both"} adds the conditional rater cuts. \code{\link{plotWrightMap}}
also accepts the result through \code{cuts}, using \code{cuts_summary}.
Plausible values and item difficulties must already share the same metric.
}
\subsection{Limits of the calculation}{
This model respects the order of rating categories without treating their
numerical codes as equally spaced. Its shared slope is more restrictive
than fitting a separate binary regression at each boundary. Assess the
proportional-odds assumption, the pattern of rater and item effects, and
sensitivity to influential observations before adopting cuts.

No cut-score confidence intervals are computed. Standard errors in the
stored model concern the fitted model and treat the input difficulties as
known. They do not propagate item-calibration uncertainty, dependence
created by panel discussion, or other sources of uncertainty outside this
model. A small variance component or a precise model fit is not evidence
that the performance-level descriptors are substantively valid.
}
}
\value{
A list of class \code{cutsIDMOrdinal}, including:
\describe{
\item{cuts_summary}{One-row tibble of reference cuts, with columns named
by \code{cut_labels}, on the original item-difficulty scale.}
\item{cuts_per_person}{Conditional rater cuts, with a \code{person}
column followed by the cut columns; \code{NULL} when
\code{per_rater = FALSE}.}
\item{cut_diagnostics, diagnostics_per_person}{Diagnostic tables for the
reference and conditional rater cuts. They identify each boundary and cut,
its status, warnings, and whether it lies outside the observed range.
\code{n}, \code{n_lower}, and \code{n_upper} count retained ratings,
not unique items. \code{threshold} is the selected model threshold on
the standardized latent scale. \code{intercept} and \code{slope} describe
the displayed upper-category logit on the original difficulty scale:
\eqn{\operatorname{logit}\Pr(R>k)=\text{intercept}+\text{slope}\,x}.
The reference has \code{rater_effect = 0}; individual rows retain their
conditional rater effect. \code{min_est} and \code{max_est} give the
observed range used to flag extrapolation.
Individual diagnostics are \code{NULL} when \code{per_rater = FALSE}.}
\item{model}{The fitted \code{clmm} or \code{clm} object when available.
Its predictor \code{difficulty} uses the internal standardized scale.
\code{model$est_center} and \code{model$est_scale} retain the transformation
parameters. The model may remain available even when its diagnostics make
the resulting cuts unusable.}
\item{model_diagnostics}{One-row tibble with \code{status},
\code{converged}, \code{max_gradient}, \code{max_scaled_gradient},
\code{hessian_positive_definite}, \code{condition_number},
\code{singular}, and \code{warning}, as well as \code{est_center},
\code{est_scale}, and counts \code{n_ratings}, \code{n_items}, and
\code{n_raters}. Unavailable diagnostic quantities are \code{NA}.}
\item{rater_effects, item_effects}{Estimated conditional random
intercepts in \code{effect}, with identifiers \code{person} or
\code{item_id} and retained-rating counts \code{n}. Effects are on the
latent logit scale, not on the item-difficulty scale. Excluded effect
terms have zero effects for observed groups. Groups with no retained
ratings have \code{NA} effects.}
\item{variance_components}{Grouping factor, variance, standard deviation,
and number of observed groups for the requested random intercepts.}
\item{data_used}{Retained long-format rating data with \code{item_id},
\code{person}, \code{est}, \code{stage_label}, and \code{stage_raw}.}
\item{n_dropped}{Number of missing ratings removed.}
\item{boundaries, rating_levels, cut_labels}{Requested boundaries,
ordered category labels, and output column names.}
\item{cuts_ordered}{Whether all reference cuts are strictly increasing;
\code{NA} if any is unavailable.}
\item{random_effects, control, method}{Requested random-effect terms,
supplied optimizer controls, and a description of the fitted method.}
\item{input_format, est_col, item_id_col, rater_id_col, rating_col, missing}{
Input layout and column/missing-value settings.}
}
}
\seealso{
\code{\link{computeCutsIDM}}, \code{\link{computeCutsIDMMAPT}},
\code{\link{summary.cutsIDMOrdinal}}, \code{\link{plotCutsIDM}},
\code{\link{plotPopulationCutsIDM}}, \code{\link[ordinal]{clmm}}
}
\references{
Christensen, R. H. B. (2026).
\emph{A Tutorial on fitting Cumulative Link Mixed Models with clmm2 from
the ordinal Package}. Package vignette, version dated July 26, 2026.
See Equation (1) and pp. 1--2 for the cumulative-logit model with normal
judge effects and Laplace estimation, and pp. 5--6 for conditional modes
and reference predictions.
\url{https://stat.ethz.ch/CRAN/web/packages/ordinal/vignettes/clmm2_tutorial.pdf}.
For crossed random effects in the current \code{clmm} implementation, see
\emph{ordinal: Regression Models for Ordinal Data},
\doi{10.32614/CRAN.package.ordinal}, and
\url{https://cran.r-project.org/web/packages/ordinal/refman/ordinal.html#clmm}.

Taylor, J. E., Rousselet, G. A., Scheepers, C., and Sereno, S. C. (2023).
Rating norms should be calculated from cumulative link mixed effects
models. \emph{Behavior Research Methods}, \bold{55}, 2175--2196.
\doi{10.3758/s13428-022-01814-7}.
See \dQuote{Simulation 2: CLMMs with item and participant random effects}
for ordinal ratings with both item and participant effects.

Ferrara, S., Perie, M., and Johnson, E. (2008).
Matching the judgmental task with standard setting panelist expertise:
The Item-Descriptor (ID) Matching Method.
\emph{Journal of Applied Testing Technology}, \bold{9}(1).
See p. 12 for logistic regression as an IDM cut-location method.
\url{https://www.testpublishers.org/assets/documents/Issue\%201\%202008.pdf}.

Sireci, S. G., Baldwin, P., Martone, A., Zenisky Laguilles, A.,
Hambleton, R. K., and Han, K. T. (2006).
\emph{Massachusetts Adult Proficiency Tests Technical Manual}.
Center for Educational Assessment Research Report No. 600,
University of Massachusetts Amherst.
See pp. 54--55 for separate binary logistic regressions and the
probability-0.5 cut definition used in MAPT standard setting.
\url{https://bpb-us-e2.wpmucdn.com/websites.umass.edu/dist/5/40195/files/2021/03/MAPT_TechnicalManualv1.pdf}.
}
\examples{
## Simulated ratings with rater and item variation.
set.seed(4721)
n_items <- 60L
n_raters <- 10L
ratings <- expand.grid(item = seq_len(n_items), rater = seq_len(n_raters))
ratings$est <- seq(-3.5, 3.5, length.out = n_items)[ratings$item]
rater_shift <- rnorm(n_raters, sd = 0.7)
item_shift <- rnorm(n_items, sd = 0.65)
latent <- 1.1 * ratings$est + rater_shift[ratings$rater] +
  item_shift[ratings$item] + rlogis(nrow(ratings))
ratings$rating <- findInterval(latent, c(-1.5, -0.5, 0.5, 1.5)) + 1L

mixed_cuts <- computeCutsIDMOrdinal(
  ratings, item_id_col = "item", rater_id_col = "rater",
  rating_col = "rating", rating_levels = 1:5
)
mixed_cuts$cuts_summary
mixed_cuts$variance_components
head(mixed_cuts$rater_effects)
summary(mixed_cuts, per_rater = TRUE)

## The same data in wide format use the same item and category definitions.
wide_ratings <- tidyr::pivot_wider(
  ratings, id_cols = c(item, est), names_from = rater,
  values_from = rating, names_prefix = "Rater"
)
wide_cuts <- computeCutsIDMOrdinal(
  wide_ratings, item_id_col = "item", rating_levels = 1:5
)

## A small fixed-effects comparison, without random intercepts:
dat <- data.frame(
  est = 1:12,
  RaterA = c(1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 1, 2),
  RaterB = c(1, 1, 2, 1, 1, 2, 1, 2, 1, 2, 2, 2)
)
cuts <- computeCutsIDMOrdinal(dat, rating_levels = c(1, 2),
                              random_effects = character())
cuts$cuts_summary
cuts$cut_diagnostics
plotCutsIDM(cuts, show_aggregate = TRUE, cut_value_digits = 2)
}
