
# sampleMplus

update: May 22, 2020

author: Lijin Zhang, Rongqian Sun, Junhao Pan

* [Description](#Description)
* [Installation](#Installation)
* [Example 1: Latent Mediation Analysis](#Example-1-Latent-Mediation-Analysis)
* [Example 2: Moderated Mediation Analysis](#Example-2-Moderated-Mediation-Analysis)
* [BugsReports](#BugsReports)
* [Functions under development](#functions-under-development)

## Description

Using Monte Carlo simulation method, this "sampleMplus" package can explore the least sample size for your structural equation models.

The least sample size is chosen based on the following criteria:

For structural parameters:

1. power ≥ 0.8;
2. biases of point estimates ≤ 10%;
3. coverage rates of the frequentist confidence intervals or the Bayesian credible intervals＞ 0.91.



## Installation

You can install it  from github using Hadley Wickham's 'devtools' package. 

```r
install.packages("devtools")
library(devtools)

install_github("zhanglj37/sampleMplus")
```


## Example 1: Latent Mediation Analysis

```r
library(samplelm)

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
# if you define the first loading of latent variable as 1, the fixed loading method would be used for model identification. 
# Otherwise, the fixed variance method would be applied.

latentvar = c("X", "M", "Y")
model = '
Y ON X*0.3
	M*0.3
M ON X* 0.3;'
# define the model in Mplus synatx
# define the effect size using*

estimator = "ML" # or Bayes


sampleMplus(ly_matrix, latentvar, model, estimator, n0 = 150)


# n0: the least sample size this function return

# or choose the sample just base on the power criteria (criteria 1)
samplePower(ly_matrix, latentvar, model, estimator, n0 = 150)
```

Running process:

(1) Increase the sample size by 5 at a time, and check whether the increased sample size meets the power criteria. If it meets the criteria, terminate the increase: 

```r

Running model: sample.inp 
System command: C:\WINDOWS\system32\cmd.exe /c cd "." && "Mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 120 samples to reach a power of 0.756"

Running model: sample.inp 
System command: C:\WINDOWS\system32\cmd.exe /c cd "." && "Mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 125 samples to reach a power of 0.75"

......

Running model: sample.inp 
System command: C:\WINDOWS\system32\cmd.exe /c cd "." && "Mplus" "sample.inp" 
Reading model:  sample.out 
[1] "This model needs at least 135 samples to reach a power of 0.8"
```

(2) Increase the sample size by 5 at a time, and check whether the increased sample size meets the criteria 2 - 3

```r
[1] "try the sample size: 135"

Running model: sample.inp 
System command: C:\WINDOWS\system32\cmd.exe /c cd "." && "Mplus" "sample.inp" 
Reading model:  sample.out 
$bias_violation
numeric(0)

$coverage_violation
numeric(0)

$sample_size
[1] 135

$checking_results
$checking_results$bias_violation
numeric(0)

$checking_results$coverage_violation
numeric(0)

## Interpretation:
## criteria 2 & 3 are satisfied
## the least sample size is 135

```



Example of Mplus input file:

```
TITLE: Simulation for sample size determination
MONTECARLO: 
	 NAMES = x1 - x10 ;
	 NOBSERVATIONS =  135 ; 
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
library(samplelm)

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
# if you define the first loading of latent variable as 1, the fixed loading method would be used for model identification. 
# Otherwise, the fixed variance method would be applied.

latentvar = c("X", "M", "Z", "Y")
model = '
Y ON X*0.3
	M*0.2
	Z*0.2;
M ON X* 0.3;
XZ | X XWITH Z;
M ON XZ*0.3;'

analysis = 'Estimator = ML;
	TYPE = RANDOM;
    ALGORITHM = INTEGRATION;'
# TYPE = RANDOM and ALGORITHM = INTEGRATION are necessary settings for latent moderation analysis.
# when the analysis part inclue settings for TYPE, ALGORITHM, INTEGRATION and other parameters, you need to define the analysis part using Mplus synatx.

sampleMplus(ly_matrix, latentvar, model, estimator, n0 = 300, analysis)

```

## BugsReports

https://github.com/zhanglj37/blcfa/issues

or contact with us: sunrq@link.cuhk.edu.hk, zhanglj37@mail2.sysu.edu.cn.

## Functions under development

Sample size determination for categorical data and multiple-group analysis.

Provide priors in Bayesian analysis.