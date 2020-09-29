/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Preprint DOI:                                                                   // PENDING

Authors:      TabareCapitan.com

Description:  This code generates tables and figures for the project

Input:        /rawData
              /code

Output:       /results/tables
              /results/figures

Replication:  Add your project path (line 27) and your pdflatex path (line 31)

Software:     Analyses run on Windows using Stata 14.2 SE

Created: 20190217 | Last modified: 20200728
*******************************************************************************/
version 14.2


*** DEFINE PROJECT PATH ********************************************************

global RUTA "D:/Dropbox/T/r/endowmentEffectInfo/analysis"

*** DEFINE pdflatex PATH *******************************************************

global PDFLATEX "C:\texlive\2019\bin\win32\pdflatex"

*** UNCOMMENT THIS SECTION FOR A CLEAN RUN ************************************* PENDING


  //..


*** INITIALIZE LOG AND RECORD SYSTEM PARAMETERS ********************************

clear

set more off

cap mkdir "$RUTA/code/logs"

cap log close

local datetime: di %tcCCYY.NN.DD!_HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'

local logfile "$RUTA/code/logs/log_`datetime'.txt"

log using "`logfile'", text

di "Begin date and time:  $S_DATE $S_TIME"
di "Stata version:        `c(stata_version)'"
di "Updated as of:        `c(born_date)'"
di "Variant:              `=cond( c(MP),"MP",cond(c(SE),"SE",c(flavor)) )'"
di "Processors:           `c(processors)'"
di "OS:                   `c(os)' `c(osdtl)'"
di "Machine type:         `c(machine_type)'"

*** USER-WRITTEN PACKAGES AND PROJECT PROGRAMS *********************************

adopath ++ "$RUTA/code/libraries/stata"

adopath ++ "$RUTA/code/programs"

*** CREATE DIRECTORIES FOR OUTPUT FILES ****************************************

cap mkdir "$RUTA/temp"
cap mkdir "$RUTA/temp/data"
cap mkdir "$RUTA/temp/figures"

cap mkdir "$RUTA/results"
cap mkdir "$RUTA/results/figures"
cap mkdir "$RUTA/results/tables"

*** RUN ANALYSIS ***************************************************************

run "$RUTA/code/main.do"

*** COPY TABLES AND FIGURES WITH PROPER NAME TO PAPER FOLDER *******************  // PENDING




*** END LOG ********************************************************************

di "End date and time: $S_DATE $S_TIME"

log close

*** END OF DOFILE **************************************************************
********************************************************************************
