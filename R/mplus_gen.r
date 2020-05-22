


mplus_gen<-function(ly_matrix, latentvar, model, estimator, nsize, analysis)
{


nx = dim(ly_matrix)[1]
nz = dim(ly_matrix)[2]



if(file.exists("sample.inp"))
{
 file.remove("sample.inp")
}


cat(
	"TITLE: Simulation for sample size determination\n", #_fix211_
	file = paste("sample.inp", sep = ''), append = T)

##### MONTECARLO
cat(
	"MONTECARLO: \n\t",
	"NAMES = x1 -", paste0("x", nx), ";\n\t",
	file = paste("sample.inp", sep = ''), append = T)


cat(
	"NOBSERVATIONS = ", nsize, "; \n\t",
	"NREPS = 500; \n\t",
	"SEED = 1234; \n",	
	file = paste("sample.inp", sep = ''), append = T)


##### MODEL POPULATION
cat(
	"\n",
	"MODEL POPULATION: \n\t",
	file = paste("sample.inp", sep = ''), append = T)

for (nzi in 1:nz)
{
	set_true(var = latentvar[nzi], ly_matrix, nzi)
}

for (nzi in 1:nz)
{
	cat(
		paste0(latentvar[nzi],"*1"), ";\n\t",
		file = paste("sample.inp", sep = ''), append = T)
}


cat(
	model, "\n\t",
	file = paste("sample.inp", sep = ''), append = T)


cat(
	"\n x1 -", paste0("x", nx, "*0.36"), ";\n\t",
	file = paste("sample.inp", sep = ''), append = T)


##### ANALYSIS
if (analysis == 'no')
{
	cat(
		"\n",
		"ANALYSIS:\n\t",
		file = paste("sample.inp", sep = ''), append = T)
	if (tolower(substr(estimator,1,1)) == "b")
	{
		cat(
			"ESTIMATOR = BAYES;\n\t",
			"PROCESS = 2; \n\t",
			"BITERATIONS = 50000(2000); \n",
			file = paste("sample.inp", sep = ''), append = T)
	}else{
		cat(
			paste0("ESTIMATOR = ", estimator), ";\n",
			file = paste("sample.inp", sep = ''), append = T)
	}
}else{
	cat(
		"\n",
		"ANALYSIS:\n\t", analysis, "\n\n\t",
		file = paste("sample.inp", sep = ''), append = T)
}


##### MODEL
cat(
	"\n",
	"MODEL: \n\t",
	file = paste("sample.inp", sep = ''), append = T)

	for (nzi in 1:nz)
	{
		fix = "variance"
		if(ly_matrix[which(ly_matrix[,nzi]!=0)[1],nzi] == 1){
			fix = "ly"
		}
		set_true(var = latentvar[nzi], ly_matrix, nzi, fix)	
	}

cat(
	"\n x1 -", paste0("x", nx, "*0.36"), ";\n\t",
	file = paste("sample.inp", sep = ''), append = T)
	
cat(
	model, "\n\n\t",
	file = paste("sample.inp", sep = ''), append = T)



cat(
	"\n",
	"OUTPUT: TECH9;\n",
	file = paste("sample.inp", sep = ''), append = T)
 
## run
runModels("sample.inp")

if(file.exists("Mplus Run Models.log"))
{
 file.remove("Mplus Run Models.log")
}

}
