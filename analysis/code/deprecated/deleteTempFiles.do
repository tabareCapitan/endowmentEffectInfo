/*******************************************************************************
Project: 			Expecting to get it: An Endowment Effect for Information

Author:				TabareCapitan.com

Description:	Delete temp files generated during the execution of main.do


Created: 20200101 | Last modified: 20200719
*******************************************************************************/
version 14.2

*** DATA ***********************************************************************

cd "$RUTA/temp/data/"

! dir *.dta /a-d /b >"$RUTA/temp/data/filelist.txt"

file open myfile using "$RUTA/temp/data/filelist.txt", read

file read myfile line

while r(eof) == 0 {

	erase `line'

	file read myfile line
}

file close myfile

erase "$RUTA/temp/data/filelist.txt"

*** FIGURES ********************************************************************

cd "$RUTA/temp/figures/"

! dir *.gph /a-d /b >"$RUTA/temp/figures/filelist.txt"

file open myfile using "$RUTA/temp/figures/filelist.txt", read

file read myfile line

while r(eof) == 0 {

	erase `line'

	file read myfile line
}

file close myfile

erase "$RUTA/temp/figures/filelist.txt"

*** END OF FILE ****************************************************************
********************************************************************************
