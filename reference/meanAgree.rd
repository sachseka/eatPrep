<!DOCTYPE html>
<!-- Generated by pkgdown: do not edit by hand --><html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"><title>mean agreement among several raters — meanAgree • eatPrep</title><!-- favicons --><link rel="icon" type="image/png" sizes="16x16" href="../favicon-16x16.png"><link rel="icon" type="image/png" sizes="32x32" href="../favicon-32x32.png"><link rel="apple-touch-icon" type="image/png" sizes="180x180" href="../apple-touch-icon.png"><link rel="apple-touch-icon" type="image/png" sizes="120x120" href="../apple-touch-icon-120x120.png"><link rel="apple-touch-icon" type="image/png" sizes="76x76" href="../apple-touch-icon-76x76.png"><link rel="apple-touch-icon" type="image/png" sizes="60x60" href="../apple-touch-icon-60x60.png"><script src="../deps/jquery-3.6.0/jquery-3.6.0.min.js"></script><meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"><link href="../deps/bootstrap-5.3.1/bootstrap.min.css" rel="stylesheet"><script src="../deps/bootstrap-5.3.1/bootstrap.bundle.min.js"></script><link href="../deps/font-awesome-6.4.2/css/all.min.css" rel="stylesheet"><link href="../deps/font-awesome-6.4.2/css/v4-shims.min.css" rel="stylesheet"><script src="../deps/headroom-0.11.0/headroom.min.js"></script><script src="../deps/headroom-0.11.0/jQuery.headroom.min.js"></script><script src="../deps/bootstrap-toc-1.0.1/bootstrap-toc.min.js"></script><script src="../deps/clipboard.js-2.0.11/clipboard.min.js"></script><script src="../deps/search-1.0.0/autocomplete.jquery.min.js"></script><script src="../deps/search-1.0.0/fuse.min.js"></script><script src="../deps/search-1.0.0/mark.min.js"></script><!-- pkgdown --><script src="../pkgdown.js"></script><meta property="og:title" content="mean agreement among several raters — meanAgree"><meta name="description" content="This is a wrapper for the agree function from the irr
package. Function computes mean agreement among several raters (at least 2) for
one item and several persons."><meta property="og:description" content="This is a wrapper for the agree function from the irr
package. Function computes mean agreement among several raters (at least 2) for
one item and several persons."><meta property="og:image" content="https://sachseka.github.io/eatPrep/logo.png"></head><body>
    <a href="#main" class="visually-hidden-focusable">Skip to contents</a>


    <nav class="navbar navbar-expand-lg fixed-top bg-light" data-bs-theme="light" aria-label="Site navigation"><div class="container">

    <a class="navbar-brand me-2" href="../index.html">eatPrep</a>

    <small class="nav-text text-muted me-auto" data-bs-toggle="tooltip" data-bs-placement="bottom" title="">1.0.2</small>


    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div id="navbar" class="collapse navbar-collapse ms-3">
      <ul class="navbar-nav me-auto"><li class="active nav-item"><a class="nav-link" href="../reference/index.html">Reference</a></li>
<li class="nav-item dropdown">
  <button class="nav-link dropdown-toggle" type="button" id="dropdown-articles" data-bs-toggle="dropdown" aria-expanded="false" aria-haspopup="true">Articles</button>
  <ul class="dropdown-menu" aria-labelledby="dropdown-articles"><li><a class="dropdown-item" href="../articles/getting_started.html">Getting Started</a></li>
  </ul></li>
      </ul><ul class="navbar-nav"><li class="nav-item"><form class="form-inline" role="search">
 <input class="form-control" type="search" name="search-input" id="search-input" autocomplete="off" aria-label="Search site" placeholder="Search for" data-search-index="../search.json"></form></li>
      </ul></div>


  </div>
</nav><div class="container template-reference-topic">
<div class="row">
  <main id="main" class="col-md-9"><div class="page-header">
      <img src="../logo.png" class="logo" alt=""><h1>mean agreement among several raters</h1>

      <div class="d-none name"><code>meanAgree.rd</code></div>
    </div>

    <div class="ref-description section level2">
    <p>This is a wrapper for the <code>agree</code> function from the <code>irr</code>
package. Function computes mean agreement among several raters (at least 2) for
one item and several persons.</p>
    </div>

    <div class="section level2">
    <h2 id="ref-usage">Usage<a class="anchor" aria-label="anchor" href="#ref-usage"></a></h2>
    <div class="sourceCode"><pre class="sourceCode r"><code><span><span class="fu">meanAgree</span><span class="op">(</span> <span class="va">dat</span> , tolerance <span class="op">=</span> <span class="fl">0</span> , weight.mean <span class="op">=</span> <span class="cn">TRUE</span> <span class="op">)</span></span></code></pre></div>
    </div>

    <div class="section level2">
    <h2 id="arguments">Arguments<a class="anchor" aria-label="anchor" href="#arguments"></a></h2>
    <p></p>
<dl><dt id="arg-dat">dat<a class="anchor" aria-label="anchor" href="#arg-dat"></a></dt>
<dd><p><!-- %%     ~~Describe \code{file} here~~ -->
Data frame with at least two columns, with examinees in the rows and raters in the columns.</p></dd>

  <dt id="arg-tolerance">tolerance<a class="anchor" aria-label="anchor" href="#arg-tolerance"></a></dt>
<dd><p><!-- %%     ~~Describe \code{file} here~~ -->
number of successive rating categories that should be regarded as rater agreement (see
help file of the <code>agree</code> function).</p></dd>

  <dt id="arg-weight-mean">weight.mean<a class="anchor" aria-label="anchor" href="#arg-weight-mean"></a></dt>
<dd><p><!-- %%     ~~Describe \code{file} here~~ -->
Logical: TRUE, if agreement is weighted by number of rater subjects. FALSE, if it is
averaged among all rater pairs.</p></dd>

</dl></div>
    <div class="section level2">
    <h2 id="value">Value<a class="anchor" aria-label="anchor" href="#value"></a></h2>
    <p>A list. First element is a data frame with proportional agreement between raters pairs.
Second element is a scalar with mean agreement among all raters.</p>
    </div>
    <div class="section level2">
    <h2 id="author">Author<a class="anchor" aria-label="anchor" href="#author"></a></h2>
    <p>Alexander Robitzsch</p>
    </div>

    <div class="section level2">
    <h2 id="ref-examples">Examples<a class="anchor" aria-label="anchor" href="#ref-examples"></a></h2>
    <div class="sourceCode"><pre class="sourceCode r"><code><span class="r-in"><span><span class="fu"><a href="https://rdrr.io/r/utils/data.html" class="external-link">data</a></span><span class="op">(</span><span class="va">rater</span><span class="op">)</span></span></span>
<span class="r-in"><span><span class="va">v01</span> <span class="op">&lt;-</span> <span class="fu"><a href="https://rdrr.io/r/base/subset.html" class="external-link">subset</a></span><span class="op">(</span><span class="va">rater</span>, <span class="va">variable</span> <span class="op">==</span> <span class="st">"V01"</span><span class="op">)</span></span></span>
<span class="r-in"><span><span class="va">dat</span> <span class="op">&lt;-</span> <span class="fu">reshape2</span><span class="fu">::</span><span class="fu"><a href="https://rdrr.io/pkg/reshape2/man/cast.html" class="external-link">dcast</a></span><span class="op">(</span> <span class="va">v01</span>, <span class="va">id</span><span class="op">~</span><span class="va">rater</span>, value.var <span class="op">=</span> <span class="st">"value"</span><span class="op">)</span></span></span>
<span class="r-in"><span><span class="va">agr</span> <span class="op">&lt;-</span> <span class="fu">meanAgree</span><span class="op">(</span><span class="va">dat</span><span class="op">[</span>,<span class="op">-</span><span class="fl">1</span><span class="op">]</span><span class="op">)</span></span></span>
</code></pre></div>
    </div>
  </main><aside class="col-md-3"><nav id="toc" aria-label="Table of contents"><h2>On this page</h2>
    </nav></aside></div>


    <footer><div class="pkgdown-footer-left">
  <p>Developed by Karoline A. Sachse, Nicole Mahler, Philipp Franikowski.</p>
</div>

<div class="pkgdown-footer-right">
  <p>Site built with <a href="https://pkgdown.r-lib.org/" class="external-link">pkgdown</a> 2.1.0.</p>
</div>

    </footer></div>





  </body></html>
