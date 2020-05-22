
sampleMplus <- function (ly_matrix, latentvar, model, estimator = 'ML', n0 = 150, analysis = 'no')
{
	samp_result = samplePower(ly_matrix, latentvar, model, estimator, n0,  analysis)
	
	if (samp_result$power >0.799)
	{
		ad_result = adjustment(ly_matrix, latentvar, model, estimator, n0 = samp_result$sample_size, analysis) 
	}
	
	print(ad_result)
}


samplePower <- function(ly_matrix, latentvar, model, estimator, n0 = 150,  analysis) {
	for (i in seq(n0,n0+1000,5)) {
	mplus_gen(ly_matrix, latentvar, model, estimator, i, analysis)
	result<-readModels("sample.out")$parameters$unstandardized
	
	locon = 0
	k = 1
	for (oni in 1:dim(result)[1])
	{
		if(substr(result[oni,1], nchar(result[oni,1])-2, nchar(result[oni,1])) == ".ON")
		{
			locon[k] = oni
			k = k + 1
		}
	}
	
	pw<-min(result$pct_sig_coef[locon])
	print(paste('This model needs at least ', i , ' samples to reach a power of ', pw,sep = ''))
	if (pw > 0.79) {n = i; p = pw; break}
	}
	samp_result = list(sample_size = n, power = pw)
	return(samp_result)
}


##### Checking 3 Muthén conditions
checking_conds<-function(ly_matrix)
{
	result<-readModels("sample.out")$parameters$unstandardized
	##### check point estimate and standard error estimate biases and coverage rate
	#loc_inter = which(result[,1] == "Intercepts")
	#loc_res = which(result[,1] == "Residual.Variances")
	#loc_var = which(result[,1] == "Variances")
	#loc_with = 0
	#k = 1
	#for (withi in 1:dim(result)[1])
	#{
	#	if(substr(result[withi,1], nchar(result[withi,1])-4, nchar(result[withi,1])) == ".WITH")
	#	{
	#		loc_with[k] = withi
	#		k = k + 1
	#	}
	#}
	#if (loc_with[1] == 0)
	#{
	#	loc_all = c(loc_inter, loc_var, loc_res)
	#}else{
	#	loc_all = c(loc_with, loc_inter, loc_var, loc_res)
	#}

	locon = 0
	k = 1
	for (oni in 1:dim(result)[1])
	{
		if(substr(result[oni,1], nchar(result[oni,1])-2, nchar(result[oni,1])) == ".ON")
		{
			locon[k] = oni
			k = k + 1
		}
	}	
	param_avg<-result$average[locon]
	param_pop<-result$population[locon]
	se_avg<-result$average_se[locon]
	se_pop<-result$population_sd[locon]
	coverage<-result$cover_95[locon]
	r1<-locon[which(!(abs(param_avg - param_pop)/param_pop <= .1))]
	#r2<-locon[which(!(abs(se_avg - se_pop)/se_pop <= .1))]
	#r3<-(abs(se_avg - se_pop)/se_pop)[loc_new] <= .05 #####21/22/33/34
	r4<-locon[which(coverage < .91 )]

	r = list(bias_violation = r1, coverage_violation=r4)
	return(r)
}


##### Adjusting sample size to meet bias and coverage criteria, if necessary 
adjustment<- function(ly_matrix, latentvar, model, estimator, n0 = 300,  analysis) 
{
	for (i in seq(n0,n0+500,5)) 
	{
		print(paste0("try the sample size: ", i))
		mplus_gen(ly_matrix, latentvar, model, estimator, i, analysis)
		checking_result = checking_conds(ly_matrix)

		print(checking_result)
		if ((length(checking_result$bias_violation) == 0)
			&( length(checking_result$coverage_violation) ==0)) {n = i; break}
	}
	ad_result = list(sample_size = n, checking_results = checking_result)
	return(ad_result)
}

