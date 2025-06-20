---
title: "ALSPAC SDQ trajectories (age only)"
output:
  html_document:
    toc: true
    toc_float: true
    keep_md: true
---

Identifying which polynomial terms to include in longitudinal models of SDQ domains for the whole sample and for males and females separately. This code fits 4 models for each SDQ domain and performs model comparisons to compare fit metrics e.g. AIC, BIC.\
   
Linear model: SDQ ~ age.cent + (1 + age.cent | ID)\
Quadratic model: SDQ ~ age.cent + age.cent^2 + (1 + age.cent | ID)\
Cubic model:  SDQ ~ age.cent + age.cent^2 + age.cent^3 + (1 + age.cent | ID)\
Quartic model:  SDQ ~ age.cent + age.cent^2 + age.cent^3 + age.cent^4 + (1 + age.cent | ID)\
  
Input data (dat) should be in long format, with the following variables (at minimum):\

- unique participant ID\
- identifier for each timepoint\
- age in years\
- mean-centred age (helpful for reducing convergence issues)\
- sex (could be sex at birth, could be gender identity - in this analysis it's a binary measure)\
- SDQ scores (conduct, emotional problems, hyperactivity, peer problems)\

Optionally, dat can include sample weights too.



# Full sample {.tabset}

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> sweep </th>
   <th style="text-align:right;"> N </th>
   <th style="text-align:left;"> age </th>
   <th style="text-align:left;"> Conduct </th>
   <th style="text-align:left;"> Emot </th>
   <th style="text-align:left;"> Hyper </th>
   <th style="text-align:left;"> Peer </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> kq </td>
   <td style="text-align:right;"> 7377 </td>
   <td style="text-align:left;"> 6.78 (0.11) </td>
   <td style="text-align:left;"> 1.6 (1.47) </td>
   <td style="text-align:left;"> 1.5 (1.66) </td>
   <td style="text-align:left;"> 3.38 (2.37) </td>
   <td style="text-align:left;"> 1.05 (1.42) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ku </td>
   <td style="text-align:right;"> 6645 </td>
   <td style="text-align:left;"> 9.64 (0.12) </td>
   <td style="text-align:left;"> 1.26 (1.41) </td>
   <td style="text-align:left;"> 1.49 (1.73) </td>
   <td style="text-align:left;"> 2.91 (2.24) </td>
   <td style="text-align:left;"> 1.1 (1.48) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> kw </td>
   <td style="text-align:right;"> 6123 </td>
   <td style="text-align:left;"> 11.71 (0.13) </td>
   <td style="text-align:left;"> 1.18 (1.4) </td>
   <td style="text-align:left;"> 1.45 (1.72) </td>
   <td style="text-align:left;"> 2.74 (2.2) </td>
   <td style="text-align:left;"> 1.09 (1.54) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ta </td>
   <td style="text-align:right;"> 5885 </td>
   <td style="text-align:left;"> 13.16 (0.18) </td>
   <td style="text-align:left;"> 1.23 (1.42) </td>
   <td style="text-align:left;"> 1.41 (1.7) </td>
   <td style="text-align:left;"> 2.88 (2.2) </td>
   <td style="text-align:left;"> 1.19 (1.61) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tc </td>
   <td style="text-align:right;"> 4805 </td>
   <td style="text-align:left;"> 16.83 (0.35) </td>
   <td style="text-align:left;"> 1 (1.33) </td>
   <td style="text-align:left;"> 1.46 (1.83) </td>
   <td style="text-align:left;"> 2.51 (2.1) </td>
   <td style="text-align:left;"> 1.1 (1.49) </td>
  </tr>
</tbody>
</table>

## Conduct problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 98546.03 </td>
   <td style="text-align:right;"> 98596.04 </td>
   <td style="text-align:right;"> -49267.01 </td>
   <td style="text-align:right;"> 98534.03 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 98440.19 </td>
   <td style="text-align:right;"> 98498.54 </td>
   <td style="text-align:right;"> -49213.09 </td>
   <td style="text-align:right;"> 98426.19 </td>
   <td style="text-align:right;"> 107.8392334 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 98338.22 </td>
   <td style="text-align:right;"> 98404.91 </td>
   <td style="text-align:right;"> -49161.11 </td>
   <td style="text-align:right;"> 98322.22 </td>
   <td style="text-align:right;"> 103.9654218 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 98340.22 </td>
   <td style="text-align:right;"> 98415.25 </td>
   <td style="text-align:right;"> -49161.11 </td>
   <td style="text-align:right;"> 98322.22 </td>
   <td style="text-align:right;"> 0.0009673 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.9751885 </td>
  </tr>
</tbody>
</table>

### Plot model (Cubic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-14-1.png)<!-- -->

## Emotional problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 112260.9 </td>
   <td style="text-align:right;"> 112310.9 </td>
   <td style="text-align:right;"> -56124.46 </td>
   <td style="text-align:right;"> 112248.9 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 112259.3 </td>
   <td style="text-align:right;"> 112317.7 </td>
   <td style="text-align:right;"> -56122.66 </td>
   <td style="text-align:right;"> 112245.3 </td>
   <td style="text-align:right;"> 3.5999693 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0577806 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 112255.5 </td>
   <td style="text-align:right;"> 112322.2 </td>
   <td style="text-align:right;"> -56119.77 </td>
   <td style="text-align:right;"> 112239.5 </td>
   <td style="text-align:right;"> 5.7958008 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0160645 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 112257.4 </td>
   <td style="text-align:right;"> 112332.4 </td>
   <td style="text-align:right;"> -56119.71 </td>
   <td style="text-align:right;"> 112239.4 </td>
   <td style="text-align:right;"> 0.1117574 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.7381522 </td>
  </tr>
</tbody>
</table>

### Plot model (Cubic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-16-1.png)<!-- -->


## Hyperactivity

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 121392.2 </td>
   <td style="text-align:right;"> 121442.2 </td>
   <td style="text-align:right;"> -60690.11 </td>
   <td style="text-align:right;"> 121380.2 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 121277.6 </td>
   <td style="text-align:right;"> 121335.9 </td>
   <td style="text-align:right;"> -60631.79 </td>
   <td style="text-align:right;"> 121263.6 </td>
   <td style="text-align:right;"> 116.64417 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 121152.7 </td>
   <td style="text-align:right;"> 121219.4 </td>
   <td style="text-align:right;"> -60568.34 </td>
   <td style="text-align:right;"> 121136.7 </td>
   <td style="text-align:right;"> 126.89341 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 121144.1 </td>
   <td style="text-align:right;"> 121219.1 </td>
   <td style="text-align:right;"> -60563.06 </td>
   <td style="text-align:right;"> 121126.1 </td>
   <td style="text-align:right;"> 10.56794 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0011507 </td>
  </tr>
</tbody>
</table>


### Plot model (Quartic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-18-1.png)<!-- -->


## Peer problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 103759.2 </td>
   <td style="text-align:right;"> 103809.2 </td>
   <td style="text-align:right;"> -51873.59 </td>
   <td style="text-align:right;"> 103747.2 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 103749.2 </td>
   <td style="text-align:right;"> 103807.6 </td>
   <td style="text-align:right;"> -51867.62 </td>
   <td style="text-align:right;"> 103735.2 </td>
   <td style="text-align:right;"> 11.935381 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0005508 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 103740.9 </td>
   <td style="text-align:right;"> 103807.6 </td>
   <td style="text-align:right;"> -51862.46 </td>
   <td style="text-align:right;"> 103724.9 </td>
   <td style="text-align:right;"> 10.323830 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0013132 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 103738.2 </td>
   <td style="text-align:right;"> 103813.2 </td>
   <td style="text-align:right;"> -51860.10 </td>
   <td style="text-align:right;"> 103720.2 </td>
   <td style="text-align:right;"> 4.701937 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0301286 </td>
  </tr>
</tbody>
</table>

### Plot model (Quartic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-20-1.png)<!-- -->


# Male only {.tabset}



## Conduct problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 50351.19 </td>
   <td style="text-align:right;"> 50397.11 </td>
   <td style="text-align:right;"> -25169.59 </td>
   <td style="text-align:right;"> 50339.19 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 50326.30 </td>
   <td style="text-align:right;"> 50379.88 </td>
   <td style="text-align:right;"> -25156.15 </td>
   <td style="text-align:right;"> 50312.30 </td>
   <td style="text-align:right;"> 26.8853060 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000002 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 50286.50 </td>
   <td style="text-align:right;"> 50347.73 </td>
   <td style="text-align:right;"> -25135.25 </td>
   <td style="text-align:right;"> 50270.50 </td>
   <td style="text-align:right;"> 41.8025366 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 50288.50 </td>
   <td style="text-align:right;"> 50357.38 </td>
   <td style="text-align:right;"> -25135.25 </td>
   <td style="text-align:right;"> 50270.50 </td>
   <td style="text-align:right;"> 0.0020182 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.9641678 </td>
  </tr>
</tbody>
</table>

### Plot model (Cubic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-22-1.png)<!-- -->

## Emotional problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 55459.51 </td>
   <td style="text-align:right;"> 55505.43 </td>
   <td style="text-align:right;"> -27723.76 </td>
   <td style="text-align:right;"> 55447.51 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 55457.60 </td>
   <td style="text-align:right;"> 55511.17 </td>
   <td style="text-align:right;"> -27721.80 </td>
   <td style="text-align:right;"> 55443.60 </td>
   <td style="text-align:right;"> 3.9114159 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0479592 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 55458.83 </td>
   <td style="text-align:right;"> 55520.06 </td>
   <td style="text-align:right;"> -27721.42 </td>
   <td style="text-align:right;"> 55442.83 </td>
   <td style="text-align:right;"> 0.7681709 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.3807835 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 55460.46 </td>
   <td style="text-align:right;"> 55529.34 </td>
   <td style="text-align:right;"> -27721.23 </td>
   <td style="text-align:right;"> 55442.46 </td>
   <td style="text-align:right;"> 0.3725608 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.5416117 </td>
  </tr>
</tbody>
</table>

### Plot model (Quadratic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-24-1.png)<!-- -->

## Hyperactivity

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 62404.85 </td>
   <td style="text-align:right;"> 62450.77 </td>
   <td style="text-align:right;"> -31196.43 </td>
   <td style="text-align:right;"> 62392.85 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 62392.29 </td>
   <td style="text-align:right;"> 62445.86 </td>
   <td style="text-align:right;"> -31189.14 </td>
   <td style="text-align:right;"> 62378.29 </td>
   <td style="text-align:right;"> 14.5671754 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0001353 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 62306.99 </td>
   <td style="text-align:right;"> 62368.21 </td>
   <td style="text-align:right;"> -31145.49 </td>
   <td style="text-align:right;"> 62290.99 </td>
   <td style="text-align:right;"> 87.2988298 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 62308.75 </td>
   <td style="text-align:right;"> 62377.63 </td>
   <td style="text-align:right;"> -31145.38 </td>
   <td style="text-align:right;"> 62290.75 </td>
   <td style="text-align:right;"> 0.2360418 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.6270796 </td>
  </tr>
</tbody>
</table>

### Plot model (Cubic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-26-1.png)<!-- -->

## Peer problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 53484.59 </td>
   <td style="text-align:right;"> 53530.51 </td>
   <td style="text-align:right;"> -26736.29 </td>
   <td style="text-align:right;"> 53472.59 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 53478.99 </td>
   <td style="text-align:right;"> 53532.57 </td>
   <td style="text-align:right;"> -26732.50 </td>
   <td style="text-align:right;"> 53464.99 </td>
   <td style="text-align:right;"> 7.595035 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0058529 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 53469.48 </td>
   <td style="text-align:right;"> 53530.70 </td>
   <td style="text-align:right;"> -26726.74 </td>
   <td style="text-align:right;"> 53453.48 </td>
   <td style="text-align:right;"> 11.517418 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0006895 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 53467.04 </td>
   <td style="text-align:right;"> 53535.93 </td>
   <td style="text-align:right;"> -26724.52 </td>
   <td style="text-align:right;"> 53449.04 </td>
   <td style="text-align:right;"> 4.432733 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0352560 </td>
  </tr>
</tbody>
</table>

### Plot model (Quartic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-28-1.png)<!-- -->

# Female only {.tabset}



## Conduct problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 48110.60 </td>
   <td style="text-align:right;"> 48156.39 </td>
   <td style="text-align:right;"> -24049.30 </td>
   <td style="text-align:right;"> 48098.60 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 48022.58 </td>
   <td style="text-align:right;"> 48076.01 </td>
   <td style="text-align:right;"> -24004.29 </td>
   <td style="text-align:right;"> 48008.58 </td>
   <td style="text-align:right;"> 90.0125487 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 47961.41 </td>
   <td style="text-align:right;"> 48022.48 </td>
   <td style="text-align:right;"> -23972.71 </td>
   <td style="text-align:right;"> 47945.41 </td>
   <td style="text-align:right;"> 63.1713320 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 47963.32 </td>
   <td style="text-align:right;"> 48032.02 </td>
   <td style="text-align:right;"> -23972.66 </td>
   <td style="text-align:right;"> 47945.32 </td>
   <td style="text-align:right;"> 0.0928166 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.7606265 </td>
  </tr>
</tbody>
</table>

### Plot model (Cubic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-31-1.png)<!-- -->


## Emotional problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 56495.59 </td>
   <td style="text-align:right;"> 56541.39 </td>
   <td style="text-align:right;"> -28241.80 </td>
   <td style="text-align:right;"> 56483.59 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 56480.14 </td>
   <td style="text-align:right;"> 56533.57 </td>
   <td style="text-align:right;"> -28233.07 </td>
   <td style="text-align:right;"> 56466.14 </td>
   <td style="text-align:right;"> 17.4530508 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0000294 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 56476.10 </td>
   <td style="text-align:right;"> 56537.17 </td>
   <td style="text-align:right;"> -28230.05 </td>
   <td style="text-align:right;"> 56460.10 </td>
   <td style="text-align:right;"> 6.0367256 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0140112 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 56477.33 </td>
   <td style="text-align:right;"> 56546.03 </td>
   <td style="text-align:right;"> -28229.67 </td>
   <td style="text-align:right;"> 56459.33 </td>
   <td style="text-align:right;"> 0.7702316 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.3801454 </td>
  </tr>
</tbody>
</table>

### Plot model (Cubic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-33-1.png)<!-- -->


## Hyperactivity

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 58492.14 </td>
   <td style="text-align:right;"> 58537.94 </td>
   <td style="text-align:right;"> -29240.07 </td>
   <td style="text-align:right;"> 58480.14 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 58357.28 </td>
   <td style="text-align:right;"> 58410.71 </td>
   <td style="text-align:right;"> -29171.64 </td>
   <td style="text-align:right;"> 58343.28 </td>
   <td style="text-align:right;"> 136.86348 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0e+00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 58317.01 </td>
   <td style="text-align:right;"> 58378.08 </td>
   <td style="text-align:right;"> -29150.51 </td>
   <td style="text-align:right;"> 58301.01 </td>
   <td style="text-align:right;"> 42.26637 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0e+00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 58302.32 </td>
   <td style="text-align:right;"> 58371.02 </td>
   <td style="text-align:right;"> -29142.16 </td>
   <td style="text-align:right;"> 58284.32 </td>
   <td style="text-align:right;"> 16.69007 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 4.4e-05 </td>
  </tr>
</tbody>
</table>

### Plot model (Quartic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-35-1.png)<!-- -->


## Peer problems

### Fit models

<table class="table" style="color: black; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> npar </th>
   <th style="text-align:right;"> AIC </th>
   <th style="text-align:right;"> BIC </th>
   <th style="text-align:right;"> logLik </th>
   <th style="text-align:right;"> -2*log(L) </th>
   <th style="text-align:right;"> Chisq </th>
   <th style="text-align:right;"> Df </th>
   <th style="text-align:right;"> Pr(&gt;Chisq) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> linear </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 50083.98 </td>
   <td style="text-align:right;"> 50129.78 </td>
   <td style="text-align:right;"> -25035.99 </td>
   <td style="text-align:right;"> 50071.98 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quadratic </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 50081.44 </td>
   <td style="text-align:right;"> 50134.87 </td>
   <td style="text-align:right;"> -25033.72 </td>
   <td style="text-align:right;"> 50067.44 </td>
   <td style="text-align:right;"> 4.5462904 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0329901 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cubic </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 50082.19 </td>
   <td style="text-align:right;"> 50143.25 </td>
   <td style="text-align:right;"> -25033.09 </td>
   <td style="text-align:right;"> 50066.19 </td>
   <td style="text-align:right;"> 1.2479848 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.2639377 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> quartic </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 50083.33 </td>
   <td style="text-align:right;"> 50152.02 </td>
   <td style="text-align:right;"> -25032.66 </td>
   <td style="text-align:right;"> 50065.33 </td>
   <td style="text-align:right;"> 0.8623668 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.3530772 </td>
  </tr>
</tbody>
</table>

### Plot model (Quadratic)

![](C:\Users\eilee\Desktop\PhD\YEAR3~1\FOODIN~2\FI_TRA~1\OUTPUT\ALSPAC\ALSPAC~1/figure-html/unnamed-chunk-37-1.png)<!-- -->
