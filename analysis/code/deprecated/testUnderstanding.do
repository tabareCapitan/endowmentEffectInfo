/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Author:       TabareCapitan.com

Description:  Identify and tag participants who did not understand the MPL

Created: 20190218 | Last modified: 20200719
*******************************************************************************/
version 14.2

*** LOAD DATA ******************************************************************

use "$RUTA/temp/data/clean.dta", clear

*** TESTS **********************************************************************

gen understanding = 1 if valid

	order understanding, after(valid)

/* 	TEST A

	After a short in-lab lecture on how to use the multiple-price list and
	four practice exercises using the computer, we asked participants to
	identify the outcome of a pre-filled multiple-price list given that a
	certain row was randomly selected. If the participant chose the wrong
	answer, we showed them a message instructing them to raise their hand and
	wait for the monitor. The monitor would them explain individually the
	multiple price list.

	Out of 219 valid participants, 30 (13.6%) failed Test A and received an
	individuallized explanation from the monitor. "					 	               	  */

tab _testA if valid


/*	TEST B

	In the next test, Test B, we asked again for the outcome of a pre-filled
	multiple-price list given that a certain row was randomly selected. This
	time there was no prompt to raise the hand if the answer was incorrect.
	Instead, we recorded this mistake and assume lack of understanding of the
	multiple-price list mechanism.

	Only 6 participants (2.74%) chose the wrong answer. We assume they did not
	understand the multiple-price list mechanism. We note that 5 out of the 6
	participants who chose the wrong answer in Test B had previously chosen
	the right answer in TestB. Only 1 participant chose the wrong answer in
	both tests.																                                  */

tab _testA _testB if valid


/* 	Finally, in Test C we asked participants to complete a multiple-price list
	but did not control to avoid inconsistent answers (jump from the right
	column to the left column. No one made that mistake.			            		  */

tab _testC if valid

/*	We assume that participants who chose the wrong answer in Test B or made a
	mistake in Test B did not understand the multiple-price list. Note that
	this lack of understanding casts doubt regarding the outcome "value of
	information" for these participants, but it does not affect the other
	outcome: "Information choice".											                        */

replace understanding = 0 if _testB == 0 | _testC == 1

drop _test*


*** SAVE DATA ******************************************************************

save "$RUTA/temp/data/cleanUnderstood.dta", replace

*** END OF FILE ****************************************************************
********************************************************************************
