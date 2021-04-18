
sampleMplus <- function (ly_matrix, latentvar, model, estimator = 'ML', N_m = 1000, analysis = 'no')
{
	samp_result = samplePower(ly_matrix, latentvar, model, estimator, N_m,  analysis)
	
	if (samp_result$power >0.799)
	{
		ad_result = adjustment(ly_matrix, latentvar, model, estimator, N_s = samp_result$sample_size, N_m, analysis) 
	}
	
	print(ad_result)
}


samplePower <- function(ly_matrix, latentvar, model, estimator, N_m = 1000,  analysis) {
	N_s = 0
	repeat{
		N_temp = ceiling((N_s+N_m)/2)
		mplus_gen(ly_matrix, latentvar, model, estimator, N_temp, analysis)
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
		print(paste('This model needs at least ', N_temp , ' samples to reach a power of ', pw,sep = ''))
		
		if (pw > 0.799) {
		if(N_m-N_temp<10){
		break
		}
		N_m=N_temp
		}else{
			N_s=N_temp
		}
	}
 
	samp_result = list(sample_size = N_temp, power = pw)
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
adjustment<- function(ly_matrix, latentvar, model, estimator, N_s, N_m = 1000,  analysis) 
{
	print(paste0("try the sample size: ", N_s))
	mplus_gen(ly_matrix, latentvar, model, estimator, N_s, analysis)
	checking_result = checking_conds(ly_matrix)

	print(checking_result)
	if ((length(checking_result$bias_violation) == 0)
		&( length(checking_result$coverage_violation) ==0)) {N_temp = N_s
	}else{
		repeat{
			N_temp = ceiling((N_s+N_m)/2)
		
			print(paste0("try the sample size: ", N_temp))
			mplus_gen(ly_matrix, latentvar, model, estimator, N_temp, analysis)
			checking_result = checking_conds(ly_matrix)

			print(checking_result)
			if ((length(checking_result$bias_violation) == 0)
				&( length(checking_result$coverage_violation) ==0)) {
					if(N_m-N_temp<10){
					break
					}
					N_m=N_temp
			}else{
				N_s=N_temp
			}
		}
	}
	ad_result = list(sample_size = N_temp, checking_results = checking_result)
	return(ad_result)
}

