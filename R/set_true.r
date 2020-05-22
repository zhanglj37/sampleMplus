


set_true <- function(var = "X", ly_matrix, nzi, fix = "NO")
{
	locv = which(ly_matrix[,nzi]!=0)
	nv = length(locv)
	
	cat(
		var, " by \n\t\t",
		file = paste("sample.inp", sep = ''), append = T)

	if (fix == "NO" || fix == "variance")
	{
		for (vi in 1:nv)
		{

			if (vi < nv)
			{
				cat(
					paste0("x", locv[vi], "*",
					ly_matrix[locv[vi], nzi]), "\n\t\t",
					file = paste("sample.inp", sep = ''), append = T)

			}else{
				cat(
					paste0("x", locv[vi], "*",
					ly_matrix[locv[vi], nzi]), "; \n\t",
					file = paste("sample.inp", sep = ''), append = T)
			}
		}
	}else if (fix == "ly")
	{
		for (vi in 1:nv)
		{

			if (vi == 1)
			{
				cat(
					paste0("x", locv[vi]), "\n\t\t",
					file = paste("sample.inp", sep = ''), append = T)

			}else if(vi == nv){
				cat(
					paste0("x", locv[vi], "*",
					ly_matrix[locv[vi], nzi]), "; \n\t",
					file = paste("sample.inp", sep = ''), append = T)
			}else{
				cat(
					paste0("x", locv[vi], "*",
					ly_matrix[locv[vi], nzi]), "\n\t\t",
					file = paste("sample.inp", sep = ''), append = T)
					
			}
		}
	
	
	}


	if (fix == "variance")
	{
		cat(
			paste0(var, "@", 1), ";\n\t",
			file = paste("sample.inp", sep = ''), append = T)
	}else if (fix == "ly")
	{
		cat(
			paste0(var, "*", 1), ";\n\t",
			file = paste("sample.inp", sep = ''), append = T)	
	}

}


