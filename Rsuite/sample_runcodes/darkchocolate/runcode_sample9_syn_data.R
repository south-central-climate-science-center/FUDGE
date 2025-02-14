########Input R parameters generated by experGen suite of tools for use in driver script -------
rm(list=ls())

#--------------predictor and target variable names--------#
	predictor.vars <- 'syn' 
	target.var <- 'syn'
#--------------grid region, mask settings----------#
        grid <- 'grid0' 
        spat.mask.dir_1 <- 'na' 
        spat.mask.var <- 'na' 
	ds.region <- 'grid0'
#--------------- I,J settings ----------------#
        file.j.range <- 'J1' 
        i.file <- 1   
        j.start <- 1 
        j.end <- 1 
        loop.start <-  j.start - (j.start-1)
        loop.end <-  j.end - (j.start-1)
#------------ historical predictor(s)----------# 
	hist.file.start.year_1 <- 1 
	hist.file.end.year_1 <- 10000
        hist.train.start.year_1 <- 1
	hist.train.end.year_1 <- 10000 
	hist.scenario_1 <- 'historical_r0i0p2'
	hist.nyrtot_1 <- (hist.train.end.year_1 - hist.train.start.year_1) + 1
	hist.model_1 <- 'Synthetic-GCM' 
	hist.freq_1 <- 'index' 
	hist.indir_1 <- '/archive/esd/PROJECTS/DOWNSCALING//SYN_DATA/FudgeTest//Synthetic-GCM/historical/index/std2p5/rand100/r0i0p2/v20150217/syn/grid0/ZeroD/' 
	hist.time.window <- 'na' 
#------------ future predictor(s) -------------# 
	fut.file.start.year_1 <- 1 
	fut.file.end.year_1 <- 10000 
        fut.train.start.year_1 <- 1 
        fut.train.end.year_1 <- 10000 
	fut.scenario_1 <- 'future_r0i0p2'
	fut.nyrtot_1 <- (fut.train.end.year_1 - fut.train.start.year_1) + 1
	fut.model_1 <- 'Synthetic-GCM' 
	fut.freq_1 <- 'index' 
	fut.indir_1 <- '/archive/esd/PROJECTS/DOWNSCALING//SYN_DATA/FudgeTest//Synthetic-GCM/future/index/std2p5/rand100/r0i0p2/v20150217/syn/grid0/ZeroD/'
	fut.time.window <- 'na'
        fut.time.trim.mask <- 'na'
#------------- target -------------------------# 
	target.file.start.year_1 <- 1 
	target.file.end.year_1 <- 10000 
        target.train.start.year_1 <- 1 
        target.train.end.year_1 <- 10000 
	target.scenario_1 <- 'historical_r0i0p2'
	target.nyrtot_1 <- (target.train.end.year_1 - target.train.start.year_1) + 1 
	target.model_1 <- 'Synthetic-Local'
	target.freq_1 <- 'index' 
        target.indir_1 <- '/archive/esd/PROJECTS/DOWNSCALING//SYN_DATA/FudgeTest//Synthetic-Local/historical/index/std2p5/rand100/r0i0p2/v20150217/syn/grid0/ZeroD/'
	target.time.window <- 'na'
#------------- method name k-fold specs-----------------------#
        ds.method <- 'CDFt' 
	ds.experiment <- 'TCsynp1-CDFt-Z01TestK00' 
	k.fold <- 0 
	
#-------------- output -----------------------#
	output.dir <- '/home/cew/Code/testing/'
	mask.output.dir <- '/home/cew/Code/testing/' 
#-------------  custom -----------------------#
        args=list(dev=1,npas=0) 
 #Number of "cuts" for which quantiles will be empirically estimated (Default is 100 in CDFt package).
#-------------- pp ---------------------------#
        mask.list <- "na"
################### others ###################################
#---------------- reference to go in globals ----------------------------------- 
	configURL <-' Ref:http://gfdl.noaa.gov/esd_experiment_configs'
# ------ Set FUDGE environment ---------------
#	FUDGEROOT = Sys.getenv(c("FUDGEROOT"))
	FUDGEROOT <- '/home/cew/Code/fudge2014/'
	print(paste("FUDGEROOT is now activated:",FUDGEROOT,sep=''))
	BRANCH <- 'undefined'
################ call main driver ###################################
print(paste("START TIME:",Sys.time(),sep=''))

#----------Use /vftmp as necessary---------------# 
#TMPDIR = Sys.getenv(c("TMPDIR"))
TMPDIR = ""
# if (TMPDIR == ""){
#   stop("ERROR: TMPDIR is not set. Please set it and try it") 
#   }
#########################################################################
gcp_to_TMPDIR <- function(directory, TMPDIR){
  if((grepl('^/archive',directory)) | (grepl('^/work',directory))){
    directory.tmp <- paste(TMPDIR,spat.mask.dir_1,sep='')
    if(!file.exists(directory.tmp)){
      #Gcp should already be loaded by setenv_fudge or the module if you are running this
      if(system('gcp --version')!=0){
        loadstr = 'source /usr/share/Modules/init/sh;module load gcp;'
      }else{
        loadstr = ""
      }
      commandstr <- paste(loadstr, "gcp -cd", directory, directory.tmp)
      sys.status <- system(commandstr)
      if (sys.status!=0){
        warning(paste("Error in gcp_to_TMPDIR; exited with status", sys.status, "; returning orig file"))
        return(directory)
      }
    }
    return(directory.tmp)
  }else{
    return(directory)
  }
}
if(spat.mask.dir_1 != 'na'){
#   if((grepl('^/archive',spat.mask.dir_1)) | (grepl('^/work',spat.mask.dir_1))){
#     spat.mask.dir_1 <- paste(TMPDIR,spat.mask.dir_1,sep='')
#   }}
spat.mask.dir_1 <- gcp_to_TMPDIR(spat.mask.dir_1, TMPDIR)
}
if(hist.indir_1 != 'na'){
  if((grepl('^/archive',hist.indir_1)) | (grepl('^/work',hist.indir_1))){
    hist.indir_1 <- paste(TMPDIR,hist.indir_1,sep='')
  }}
if(fut.indir_1 != 'na'){
  if((grepl('^/archive',fut.indir_1)) | (grepl('^/work',fut.indir_1))){
    fut.indir_1 <- paste(TMPDIR,fut.indir_1,sep='')
  }}
if(hist.indir_1 != 'na'){
  if((grepl('^/archive',hist.indir_1)) | (grepl('^/work',hist.indir_1))){
    target.indir_1 <- paste(TMPDIR,target.indir_1,sep='')
  }}
if(target.time.window != 'na'){
  if((grepl('^/archive',target.time.window)) | (grepl('^/work',target.time.window))){
    target.time.window <- paste(TMPDIR,target.time.window,sep='')
  }}
if(hist.time.window != 'na'){
  if((grepl('^/archive',hist.time.window)) | (grepl('^/work',hist.time.window))){
    hist.time.window <- paste(TMPDIR,hist.time.window,sep='')
  }}
if(fut.time.window != 'na'){
  if((grepl('^/archive',fut.time.window)) | (grepl('^/work',fut.time.window))){
    fut.time.window <- paste(TMPDIR,fut.time.window,sep='')
  }}
if(fut.time.trim.mask != 'na'){
  if((grepl('^/archive',fut.time.trim.mask)) | (grepl('^/work',fut.time.trim.mask))){
    fut.time.trim.mask <- paste(TMPDIR,fut.time.trim.mask,sep='')
  }
}
output.dir <- paste(TMPDIR,output.dir,sep='')
mask.output.dir <- paste(TMPDIR,mask.output.dir,sep='')

#########################################################################
#-------------------------------------------------#
#source(paste(FUDGEROOT,'Rsuite/Drivers/',ds.method,'/Driver_',ds.method,'.R',sep=''))
source(paste(FUDGEROOT,'Rsuite/Drivers/','Master_Driver.R',sep=''))
