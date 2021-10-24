
# sampleMplus

update: Apr 18, 2021

author: Lijin Zhang, Rongqian Sun, Junhao Pan

* [Description](#Description)
* [Installation](#Installation)
* [Example 1: Latent Mediation Analysis](#Example-1-Latent-Mediation-Analysis)
* [Example 2: Moderated Mediation Analysis](#Example-2-Moderated-Mediation-Analysis)
* [BugsReports](#BugsReports)
* [Functions under development](#functions-under-development)

## Description

Using Monte Carlo simulation method and the binary search, this "sampleMplus" package can provide sample size recommendation for your structural equation models.

The sample size is chosen based on the following criteria:

For structural parameters:

1. power ≥ 0.8;
2. biases of point estimates ≤ 10%;
3. coverage rates of the frequentist confidence intervals or the Bayesian credible intervals ＞ 0.91.

## Installation

You can install it  from github using Hadley Wickham's 'devtools' package. 

```r
install.packages("devtools")
library(devtools)

install_github("zhanglj37/sampleMplus")
```


## Example 1: Latent Mediation Analysis

```r
library(sampleMplus)

example model: https://www.lijinzhang.xyz/images/samplelm.jpg

# the effect size you should provide: loadings, structural coefficients
ly_matrix = matrix(c(
  1,0,0,
  0.8,0,0,
  0.8,0,0,
  0,1,0,
  0,0.8,0,
  0,0.8,0,
  0,0,1,
  0,0,0.8,
  0,0,0.8,
  0,0,0.8
),ncol=3,byr=T)
# the loading matrix
# the first-third column: the loadings for X, M, Y
# if you define the first loading of latent variable at 1, the first loading would be fixed for model identification. 
# Otherwise, the variance of latent variable would be fixed@1.

latentvar = c("X", "M", "Y")
model = '
Y ON X*0.3
	M*0.3;
M ON X* 0.3;'
# define the model in Mplus synatx
# define the effect size using*

estimator = "ML" # or Bayes


sampleMplus(ly_matrix, latentvar, model, estimator, N_m = 300)


# search the appropriate sample size between 0 and N_m

# or choose the sample just base on the power criteria (criteria 1)
samplePower(ly_matrix, latentvar, model, estimator, N_m = 300)
```

Running process:

running time < 1 minute with MacOS system, i5-9400f CPU@2.9GHZ, 16GB memory

(1) search the appropriate sample size between 0 and N_m using the binary search,  check whether the criteria 1 is satisfied, stop when (a) the slected sample size meet the crietria for the power; (b) |the selected sample size - upper bound of the current binary search| < 10: 

```r

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 150 samples to reach a power of 0.81"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 75 samples to reach a power of 0.47"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 113 samples to reach a power of 0.67"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 132 samples to reach a power of 0.76"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 141 samples to reach a power of 0.79"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 146 samples to reach a power of 0.8"

```

(2) search the appropriate sample size between the selected sample size and N_m using the binary search, and check whether the criteria 2 - 3 is satisfied

```r
[1] "try the sample size: 146"

Reading model:  sample.out 
$bias_violation
numeric(0)

$coverage_violation
numeric(0)

## Interpretation:
## criteria 2 & 3 are satisfied
## the least sample size is 146

```



Example of Mplus input file:

```
TITLE: Simulation for sample size determination
MONTECARLO: 
	 NAMES = x1 - x10 ;
	 NOBSERVATIONS =  146 ; 
	 NREPS = 500; 
	 SEED = 1234; 

MODEL POPULATION: 
	X  by 
		x1*1 
		x2*0.8 
		x3*0.8 ; 
	M  by 
		x4*1 
		x5*0.8 
		x6*0.8 ; 
	Y  by 
		x7*1 
		x8*0.8 
		x9*0.8 
		x10*0.8 ; 
	X*1 ;
	M*1 ;
	Y*1 ;
	
    Y ON X*0.3
    M*0.3;
    M ON X* 0.3; 
	
 	x1 - x10*0.36 ;
	
 ANALYSIS:
	ESTIMATOR = ML ;

 MODEL: 
	X  by 
		x1 
		x2*0.8 
		x3*0.8 ; 
	X*1 ;
	M  by 
		x4 
		x5*0.8 
		x6*0.8 ; 
	M*1 ;
	Y  by 
		x7 
		x8*0.8 
		x9*0.8 
		x10*0.8 ; 
	Y*1 ;
	
    x1 - x10*0.36 ;
	
    Y ON X*0.3
    M*0.3;
    M ON X* 0.3; 

	
 OUTPUT: TECH9;

```

## Example 2: Moderated Mediation Analysis

```r
library(sampleMplus)

# the effect size you should provide: loadings, structural coefficients
ly_matrix = matrix(c(
  1,0,0,0,
  0.8,0,0,0,
  0.8,0,0,0,
  0,1,0,0,
  0,0.8,0,0,
  0,0.8,0,0,
  0,0,1,0,
  0,0,0.8,0,
  0,0,0.8,0,
  0,0,0.8,0,
  0,0,0,1,
  0,0,0,0.8,
  0,0,0,0.8
),ncol=4,byr=T)
# the loading matrix
# the first-forth column: the loadings for X, M, Z, Y


latentvar = c("X", "M", "Z", "Y")
model = '
Y ON X*0.3
	M*0.2
	Z*0.2;
M ON X* 0.3;
XZ | X XWITH Z;
M ON XZ*0.3;'

estimator = "ML" # or Bayes
analysis = 'Estimator = ML;
	TYPE = RANDOM;
    ALGORITHM = INTEGRATION;'
# TYPE = RANDOM and ALGORITHM = INTEGRATION are necessary settings for latent moderation analysis.
# when the analysis part inclue settings for TYPE, ALGORITHM, INTEGRATION and other parameters, you need to define the analysis part using Mplus synatx.

sampleMplus(ly_matrix, latentvar, model, estimator, N_m = 500, analysis)

```

```r

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 250 samples to reach a power of 0.75"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 375 samples to reach a power of 0.88"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 313 samples to reach a power of 0.81"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 282 samples to reach a power of 0.77"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 298 samples to reach a power of 0.79"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 306 samples to reach a power of 0.84"
[1] "try the sample size: 306"

Running model: sample.inp 
System command: cd "." && "/Applications/Mplus/mplus" "sample.inp" 
Reading model:  sample.out 
$bias_violation
numeric(0)

$coverage_violation
numeric(0)

$sample_size
[1] 306

$checking_results
$checking_results$bias_violation
numeric(0)

$checking_results$coverage_violation
numeric(0)


## the least sample size is 306

```

## BugsReports

https://github.com/zhanglj37/sampleMplus/issues

or contact with us: sunrq@link.cuhk.edu.hk, zhanglj37@mail2.sysu.edu.cn.

## Functions under development

Sample size determination for categorical data and multiple-group analysis.

Simulation with non-normally distributed datasets

Replace the complex measurement models with single-indicator models in the simulation. In this way, researchers can set the measurement models easily based on the reliability of the scale.
