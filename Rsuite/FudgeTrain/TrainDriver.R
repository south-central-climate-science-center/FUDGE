TrainDriver <- function(target.masked.in, hist.masked.in, fut.masked.in, ds.var='tasmax', 
                        mask.list, ds.method=NULL, k=0,  
                        create.ds.out=TRUE,
                        time.steps=NA, istart = NA,loop.start = NA,loop.end = NA, downscale.args=NULL, 
                        ds.orig=NULL, #Correcting a dimension error
                        s3.instructions=list(onemask=list('na')),
                        s5.instructions=list(onemask=list('na')), create.qc.mask=FALSE){
  #' Function to loop through spatially,temporally and call the Training guts.
  #' @param target.masked.in, hist.masked.in, fut.masked.in: The historic target/predictor and 
     #' future predictor datasets to which spatial masks have been applied earlier
     #' in the main driver function
     #' @param mask.list: The list of time windowing masks and their corresponding
     #' time series to be applied to the time windows; returned from CreateTimeWindowList
     #' @param ds.method: name of the downscaling method to be applied to the data.
     #' A list of downscaling methods currently accepted are located in the master 
     #' @param downscale.args: Named list of arguments used in the downscaling function.
     #' downscaling method sheet (documents/)
     #' @param k: The number of k-fold cross-validation steps to be performed. If k > 1, 
     #' kfold masks will be generated during TrainDriver.
     #' --------------Adjustment steps --------------
     #' @param s3.instructions: Instructions for performing pre-downscaling adjustment
     #' @param s5.instructions: Instructions for performing post-downscaling adjustment
     #' and/or creation of a QC mask
     #' ---Optional arguments for use in debugging---
     #' @param  loop.start: J loop start index
     #' @param loop.end: J loop end index
     #' @param time.steps: the # time steps; defaults to NA
     #' @param istart: I loop start index
     
     
     # Initialize ds.vector 
     message("Entering downscaling driver function")
     if(create.ds.out){
       #Should only be false if explicitly running with the intent of creating only
       #a QC mask - all other cases produce *some* ds.out
       ds.vector =  array(NA,dim=c(dim(fut.masked.in))) #c(istart,loop.end,time.steps)
     }else{
       ds.out <- NULL
     }
     if(create.qc.mask){
       qc.mask <-  array(NA,dim=c(dim(fut.masked.in)))
       s5.adjust <- TRUE
     }else if(length(s5.instructions) > 0){
       qc.mask <- NULL
       s5.adjust <- TRUE #It's binary: you either make adjustments, or create a qc mask. It never does nothing.
     }else{
       #If s5.instructions=='na'
       qc.mask <- NULL
       s5.adjust <- FALSE
     }
     
     if(length(s3.instructions!=0)){ #!is.null(s3.instructions[[1]])
       #All pre-processing can do is adjust values; that will always happen
       s3.adjust <- TRUE
     }else{
       s3.adjust <- FALSE
     }
     
     
     print(k)
     if(k>1){
       #Create Kfold cross-validation mask
       print('Cross-validation not supported at this time')
     }else{
       #Create mask for which all values are TRUE
       kfold.mask=list('na')
     }   
     #TODO CEW: Add the cross-validation mask creation before looping over the timeseries
     #(assumes that all time series will be of same length)
     #Also keep in mind: both the time windows and the kfold masks are, technically, 
     #time masks. You're just doing a compression step immediately after one but not the other.
     print(dim(target.masked.in))
     for(i.index in 1:length(target.masked.in[,1,1])){  #Most of the time, this will be 1
       for(j.index in 1:length(target.masked.in[1,,1])){
         if(sum(!is.na(target.masked.in[i.index,j.index,]))!=0 &&
              sum(!is.na(hist.masked.in[i.index,j.index,]))!=0 &&
              sum(!is.na(fut.masked.in[i.index,j.index,]))!=0){
           message(paste("Begin processing point with i = ", i.index, "and j =", j.index))
           loop.temp <- LoopByTimeWindow(train.predictor = hist.masked.in[i.index, j.index,], 
                                         train.target = target.masked.in[i.index, j.index,], 
                                         esd.gen = fut.masked.in[i.index, j.index,], 
                                         ds.var=ds.var,
                                         mask.struct = mask.list, 
                                         create.ds.out=create.ds.out, downscale.fxn = ds.method, downscale.args = downscale.args, 
                                         kfold=k, kfold.mask=kfold.mask, graph=FALSE, masklines=FALSE, 
                                         ds.orig=ds.orig[i.index, j.index,],
                                         #s5.adjust=s5.adjust, s5.method=s5.method, s5.args = s5.args, 
                                         s3.instructions=s3.instructions, s3.adjust=s3.adjust,
                                         s5.instructions=s5.instructions, s5.adjust=s5.adjust,
                                         create.qc.mask=create.qc.mask, create.adjust.out=create.adjust.out
           )
           if (create.ds.out || create.adjust.out){
             #If we are not in the "write only the qc data" case
             ds.vector[i.index, j.index,] <- loop.temp$downscaled
           }
           if(create.qc.mask){
             qc.mask[i.index, j.index, ] <- loop.temp$qc.mask
           }
         }else{
           #Nothing needs to be done because there is already a vector of NAs of the right dimensions inititalized.
           message(paste("Too many missing values in i =", i.index,",", "j =", j.index,"; skipping without downscaling"))
         }
       }
     }
     ####### Loop(1) ends ###################################
     return(list('esd.final' = ds.vector, 'qc.mask' = qc.mask)) #'postproc.out'=postproc.out))
     ############## end of TrainDriver.R ############################
}