\name{criterion}
\alias{criterion}
\alias{criterion.dist}
\alias{criterion.matrix}
\alias{criterion.array}
\title{Criterion for a Loss/Merit Function for Data Given a Permutation}
\description{
Compute the value for different loss functions \eqn{L} and
merit function \eqn{M} for
  data given a permutation.
}
\usage{
criterion(x, order = NULL, method = NULL, force_loss = FALSE, ...)
}
\arguments{
  \item{x}{an object of class \code{dist} or a matrix (currently no
    functions are implemented for array).}
  \item{order}{an object of class \code{ser_permutation} suitable for
    \code{x}.  If \code{NULL}, the identity permutation is used.
  }
  \item{method}{a character vector with the names of the criteria to be
    employed, or \code{NULL} (default) in which case all available
    criteria are used.}
  \item{...}{additional parameters passed on to the criterion method.}
  \item{force_loss}{logical; should merit function be converted into
    loss functions by multiplying with -1?}
}
\details{
For a symmetric dissimilarity matrix
\eqn{D} with elements \eqn{d(i,j)} where \eqn{i, j = 1 \ldots n},
the aim is generally to place low distance values close to the diagonal.
The following criteria to judge the quality of a
certain permutation of the objects in a dissimilarity matrix
are currently implemented (for a more detailed description and an
experimental comparison see Hahsler (2017)):
\describe{

\item{\code{"Gradient_raw", "Gradient_weighted"}}{Gradient measures
    (Hubert et al 2001).
    A symmetric dissimilarity matrix
    where the values in all rows and columns only increase when
    moving away from the main diagonal is called a perfect
    \emph{anti-Robinson matrix} (Robinson 1951). A suitable merit
    measure which quantifies the divergence of a matrix from the
    anti-Robinson form is

    \deqn{
    M(D) = \sum_{i=1}^n \sum_{i<k<j} f(d_{ij}, d_{ik}) + \sum_{i<k<j} f(d_{ij}, d_{kj})}
    where \eqn{f(.,.)}
    is a function which defines how a violation
    or satisfaction
    of a gradient condition for an object triple (\eqn{O_i, O_k, O_j})
    is counted.

    Hubert et al (2001) suggest two functions. The first
    function is given by:
    \deqn{f(z,y) = sign(y-z) = +1 if z < y; 0 if z = y; and -1 if z > y.}

    It results in raw number of triples satisfying the gradient
    constraints minus triples which violate the constraints.

    The second function is defined as:
    \deqn{f(z,y) = |y-z| sign(y-z) = y-z}
    It weights the each satisfaction or violation by the difference by
    its magnitude given by the absolute difference between the values.
}

\item{\code{"AR_events", "AR_deviations"}}{Anti-Robinson events (Chen 2002).
    An even simpler loss function can be created in the same way as the gradient
    measures above by concentrating on violations only.
    \deqn{
        L(D) =
        \sum_{i=1}^n \sum_{i<k<j} f(d_{ik}, d_{ij}) + \sum_{i<k<j} f(d_{kj}, d_{ij})
    }

    To only count the violations we use
    \deqn{
        f(z, y) = I(z, y) = 1 if z < y and 0 otherwise.
   }


   \eqn{I(\cdot)} is an indicator function returning 1 only for violations.
   Chen (2002) presented a formulation for an equivalent
loss function and called the violations \emph{anti-Robinson events}
and also introduced a weighted versions of the loss
function resulting in
\deqn{
        f(z, y) = |y-z|I(z, y)
    }
    using the absolute deviations as weights.
}

\item{\code{"RGAR"}}{Relative generalized Anti-Robinson events (Tien et al 2008).
    Counts Anti-Robinson events in a variable band
    (window specified by \code{w} defaults to the maximum of \eqn{n-1}) around the main diagonal and normalizes by
    the maximum of possible events.

    \deqn{
        L(D) = 1/m
        \sum_{i=1}^n \sum_{(i-w)\le j<k<i} I(d_{ij} < d_{ik}) + \sum_{i<j<k\le(i+w))} I(d_{ij} > d_{ik})
    }

    where \eqn{m=(2/3-n)w + nw^2 - 2/3 w^3}, the maximal number
    of possible anti-Robinson events in the window.
  The window size \eqn{w} represents the number of neighboring objects (number of entries from the diagonal of the distance matrix) are considered. The window size is \eqn{2 \le w < n}, where smaller values result in
  focusing on the local structure while larger values look at the global structure. Alternatively, \code{pct} can be used instead of \code{w} to
  specify the window as a percentage of \eqn{n}. \code{relative=FALSE} can be
 to get the GAR, i.e., the absolute number of AR events in the window.
}

\item{\code{"BAR"}}{Banded Anti-Robinson Form (Earle and Hurley 2015).

    Simplified measure for closeness to the anti-Robinson form in a band of
    size \eqn{b} with \eqn{1 <= b < n} around the diagonal.

    \deqn{
        L(D) =
        \sum_{|i-j|<=b} (b+1-|i-j|) d_{ij}
    }

    For \eqn{b=1} the measure reduces to the Hamiltonian path length.
    For \eqn{b=n-1} the measure is equivalent to ARc defined
    (Earle and Hurley, 2015). Note that ARc is equivalent to the
    Linear Seriation criterion (scaled by 1/2).

    \eqn{b} defaults to a band of 20\% of \eqn{n}.
}



\item{\code{"Path_length"}}{Hamiltonian path length (Caraux and Pinloche 2005).

    The order of the objects in a dissimilarity matrix corresponds to a path
    through a graph where each node represents an object and is visited exactly
    once, i.e., a Hamilton path. The length of the path is defined as the sum
    of the edge weights, i.e., dissimilarities.

    \deqn{L(D) = \sum_{i=1}^{n-1} d_{i,i+1}}

    The length of the Hamiltonian path is equal to the
    value of the minimal span loss function (as used by Chen 2002).
    Both notions are related to the \emph{traveling salesperson problem (TSP).}

    If \code{order} is not unique or
    there are non-finite distance values \code{NA} is returned.}

\item{\code{"Lazy_path_length"}}{Lazy path length (Earl and Hurley 2015).

    A weighted version of the Hamiltonian path criterion. This loss function
    postpones larger distances to later in the order (i.e., a lazy traveling
    sales person).

    \deqn{L(D) = \sum_{i=1}^{n-1} (n-i) d_{i,i+1}}

    Earl and Hurley (2015) proposed this criterion for reordering in
    visualizations to concentrate on closer objects first.
    }


\item{\code{"Inertia"}}{Inertia criterion (Caraux and Pinloche 2005).

    Measures the moment of the inertia of dissimilarity values
    around the diagonal as

    \deqn{M(D) = \sum_{i=1}^n \sum_{j=1}^n d(i,j)|i-j|^2}

    \eqn{|i-j|} is used as a measure for the distance to the diagonal and
    \eqn{d(i,j)} gives the weight. This criterion gives higher weight
    to values farther away from the diagonal. It increases with quality.}


\item{\code{"Least_squares"}}{Least squares criterion (Caraux and Pinloche 2005).

    The sum of squares of deviations between the
    dissimilarities and rank differences (in the matrix) between two
    elements:
    \deqn{L(D) = \sum_{i=1}^n \sum_{j=1}^n (d(i,j) - |i-j|)^2,}
    where \eqn{d(i,j)} is an element of the dissimilarity matrix \eqn{D} and
    \eqn{|i-j|} is the rank difference between the objects.

    Note that if Euclidean distance is used to calculate \eqn{D} from
    a data matrix \eqn{X}, the order of the elements in \eqn{X} by projecting
    them on the first principal component of \eqn{X} minimizes this criterion.
    The least squares criterion is related to
    \emph{unidimensional scaling.}
    }

    \item{\code{"LS"}}{Linear Seriation Criterion (Hubert and Schultz 1976).

    Weights the distances with the absolute rank differences.

    \deqn{L(D) \sum_{i,j=1}^n d(i,j) (-|i-j|)}
    }

    \item{\code{"2SUM"}}{2-Sum Criterion (Barnard, Pothen, and Simon 1993).

    The 2-Sum
    loss criterion multiplies the similarity between objects
    with the squared rank differences.

    \deqn{L(D) \sum_{i,j=1}^n 1/(1+d(i,j)) (i-j)^2,}

    where \eqn{s(i,j) = 1/(1+d(i,j))} represents the similarity between
    objects \eqn{i} and \eqn{j}.
    }

    \item{\code{"ME"}, \code{"Moore_stress"},
          \code{"Neumann_stress"}, \code{"Cor_R"}}{These
    criteria are defined on general matrices (see below for definitions).
    The dissimilarity matrix is first converted into a similarity matrix
    using \eqn{S = 1/(1+D)}. If a different transformation is required, then
    perform the transformation first and supply a matrix instead
    of a dist object.}
    }

For a general matrix
\eqn{X = x_{ij}}, \eqn{i = 1 \ldots n} and \eqn{j = 1 \ldots m},
currently the
following loss/merit functions
are implemented:

\describe{
\item{\code{"ME"}}{Measure of
    Effectiveness (McCormick 1972).

    The measure of effectiveness (ME) for matrix
    \eqn{X}, is defined as

    \deqn{M(X) = 1/2 \sum_{i=1}^{n} \sum_{j=1}^{m} x_{i,j}(x_{i,j-1}+x_{i,j+1}+x_{i-1,j}+x_{i+1,j})}

    with, by convention

    \deqn{x_{0,j}=x_{m+1,j}=x_{i,0}=x_{i,n+1}=0.}

    ME is a merit measure,
    i.e. a higher ME indicates a better arrangement.
    Maximizing ME is the objective of the bond energy algorithm
    (BEA).
}

\item{\code{"Cor_R"}}{Weighted correlation coefficient R developed
     as the Measure of Effectiveness for the Moment Ordering
     Algorithm (Deutsch and Martin 1971).

     R is a merit measure normalized so that its value always
     lies in \eqn{[-1,1]}.
     For the special case of a square matrix \eqn{R=1} corresponds to only the
     main diagonal being filled, \eqn{R=0} to a random distribution of value
     throughout the array, and \eqn{R=-1} to the opposite diagonal only being
     filled.
}

\item{\code{"Moore_stress"}, \code{"Neumann_stress"}}{ Stress (Niermann 2005).

Stress measures the conciseness of the presentation of a matrix/table and can
be seen as a purity function which compares the values in a matrix/table with
its neighbors. The stress measure used here is computed as the sum of squared
distances of each matrix entry from its adjacent entries.

\deqn{
    L(X) =
    \sum_{i=1}^n \sum_{j=1}^m \sigma_{ij}
}

The following types
of neighborhoods are available:

  \describe{
    \item{Moore:}{comprises the eight adjacent entries.
    \deqn{   \sigma_{ij} = \sum_{k=\max(1,i-1)}^{\min(n,i+1)}
                \sum_{l=\max(1,j-1)}^{\min(m,j+1)}
                (x_{ij} - x_{kl})^2
}
    }
    \item{Neumann:}{comprises the four adjacent entries.
    \deqn{
     \sigma_{ij} =
            \sum_{k=\max(1,i-1)}^{\min(n,i+1)} (x_{ij} - x_{kj})^2 +
            \sum_{l=\max(1,j-1)}^{\min(m,j+1)} (x_{ij} - x_{il})^2
    }
    }
  }

  The major difference between the Moore and the Neumann
  neighborhood is that for
  the later the contribution of row and column permutations to stress are
  independent and thus can be optimized independently.
  }
}
}
\value{
  A named vector of real values.
}
\references{
Barnard, S.T.,  A. Pothen, and H. D. Simon (1993): A Spectral Algorithm for Envelope Reduction of Sparse Matrices. \emph{In Proceedings of the 1993
ACM/IEEE Conference on Supercomputing,} 493--502. Supercomputing '93.
New York, NY, USA: ACM.

Caraux, G. and S. Pinloche (2005): Permutmatrix: A Graphical Environment
to Arrange Gene Expression Profiles in Optimal Linear Order,
\emph{Bioinformatics,}
\bold{21}(7), 1280--1281.

Chen, C.-H. (2002): Generalized association plots:
Information visualization via iteratively generated correlation matrices,
\emph{Statistica Sinica,} \bold{12}(1), 7--29.

Deutsch, S.B. and J.J. Martin (1971):
An ordering algorithm for analysis of data arrays.
\emph{Operational Research,} \bold{19}(6), 1350--1362.
\doi{10.1287/opre.19.6.1350}


Earle, D. and C.B. Hurley (2015): Advances in Dendrogram Seriation for Application to Visualization. \emph{Journal of Computational and Graphical Statistics,}
\bold{24}(1), 1--25.
\doi{10.1080/10618600.2013.874295}

Hahsler, M. (2017): An experimental comparison of seriation methods for one-mode two-way data. \emph{European Journal of Operational Research,} \bold{257}, 133--143. \doi{10.1016/j.ejor.2016.08.066}

Hubert, L. and J. Schultz (1976): Quadratic Assignment as a General Data Analysis Strategy. \emph{British Journal of Mathematical and Statistical
Psychology,} \bold{29}(2). Blackwell Publishing Ltd. 190--241.
\doi{10.1111/j.2044-8317.1976.tb00714.x}


Hubert, L., P. Arabie, and J. Meulman (2001): \emph{Combinatorial Data Analysis:
Optimization by Dynamic Programming.} Society for Industrial Mathematics. \doi{10.1137/1.9780898718553}

Niermann, S. (2005): Optimizing the Ordering of Tables
With Evolutionary Computation, \emph{The American Statistician,}
\bold{59}(1), 41--46.
\doi{10.1198/000313005X22770}

McCormick, W.T., P.J. Schweitzer and T.W. White (1972):
Problem decomposition and data reorganization by a clustering technique,
\emph{Operations Research,}
\bold{20}(5), 993-1009.
\doi{10.1287/opre.20.5.993}

Robinson, W.S. (1951): A method for chronologically ordering archaeological deposits,
\emph{American Antiquity,} \bold{16}, 293--301.
\doi{10.2307/276978}

Tien, Y-J., Yun-Shien Lee, Han-Ming Wu and Chun-Houh Chen (2008):
Methods for simultaneously identifying coherent local clusters with
smooth global patterns in gene expression profiles,
\emph{BMC Bioinformatics,} \bold{9}(155), 1--16.
\doi{10.1186/1471-2105-9-155}
}

\seealso{
\code{\link{list_criterion_methods}} to query the criterion registry.
}


\author{Christian Buchta and Michael Hahsler}
\examples{
## create random data and calculate distances
m <- matrix(runif(20),ncol=2)
d <- dist(m)

## get an order for rows (optimal for the least squares criterion)
o <- seriate(d, method = "MDS")
o

## compare the values for all available criteria
rbind(
    unordered = criterion(d),
    ordered = criterion(d, o)
)

## compare RGAR by window size (from local to global)
w <- 2:(nrow(m)-1)
RGAR <- sapply(w, FUN = function (w)
  criterion(d, o, method="RGAR", w = w))
plot(w, RGAR, type = "b", ylim = c(0,1),
  xlab = "Windows size (w)", main = "RGAR by window size")
}
\keyword{cluster}
