/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Authors:      TabareCapitan.com
              klaas@uwyo.edu

Description:  Calculate value of information (from MPL data) under
              alternative assumptions


Created: 20190217 | Last modified: 20200719
*******************************************************************************/
version 14.2

*** LOAD DATA ******************************************************************

use "$RUTA/temp/data/cleanNoOutliers.dta", clear

*** ONLY FOR PEOPLE WHO UNDERSTOOD *********************************************

global gotIt "understanding == 1"

*** CALCULATIONS ***************************************************************

/*For subjects initially endowed with info who chose to remove it, calculate
  the WTA to keep the  info on after all. The 10 options offered to them as an
  alternative to "Remove calorie information" (coded as 0) were

  (1 ) Keep and see calorie information + $0.01
  (2 ) Keep and see calorie information + $0.25
  (3 ) Keep and see calorie information + $0.50
  (4 ) Keep and see calorie information + $0.75
  (5 ) Keep and see calorie information + $1.00
  (6 ) Keep and see calorie information + $1.50
  (7 ) Keep and see calorie information + $2.00
  (8 ) Keep and see calorie information + $2.50
  (9 ) Keep and see calorie information + $3.00
  (10) Keep and see calorie information + $5.00

  A subject who chose 1 for all 10 options is willing to accept info for some
  value on interval ]$0,$0.01]. A subject who chose 0 for the first option,
  but 1 for all remaining 9 options is willing to accept info for some value
  on interval ]$0.01,$0.25]. Etc. If we take the midpoint of the intervals to
  be their WTA, and conservatively use $5.00 for the WTA of subjects who
  chose 0 for all 10 options, we get WTA values

  (1 ) 0.5($0.00 + $0.01) = $0.005
  (2 ) 0.5($0.01 + $0.25) = $0.13
  (3 ) 0.5($0.25 + $0.50) = $0.375
  (4 ) 0.5($0.50 + $0.75) = $0.625
  (5 ) 0.5($0.75 + $1.00) = $0.875
  (6 ) 0.5($1.00 + $1.50) = $1.25
  (7 ) 0.5($1.50 + $2.00) = $1.75
  (8 ) 0.5($2.00 + $2.50) = $2.25
  (9 ) 0.5($2.50 + $3.00) = $2.75
  (10) 0.5($3.00 + $5.00) = $4.00
  (11)             $5.00

  Since we ensured in Qualtrics that answers never had 0's following 1's, we
  can calculate the WTA using the following code, which maps the total number
  of 1's to the WTA.                                                          */

egen wta_rtki = rowtotal(wta_remove_to_keepon_*) if $gotIt , missing

gen wta_rtk = .

  replace wta_rtk = 0.005 if wta_rtki == 10
  replace wta_rtk = 0.13  if wta_rtki == 9
  replace wta_rtk = 0.375 if wta_rtki == 8
  replace wta_rtk = 0.625 if wta_rtki == 7
  replace wta_rtk = 0.875 if wta_rtki == 6
  replace wta_rtk = 1.25  if wta_rtki == 5
  replace wta_rtk = 1.75  if wta_rtki == 4
  replace wta_rtk = 2.25  if wta_rtki == 3
  replace wta_rtk = 2.75  if wta_rtki == 2
  replace wta_rtk = 4.00  if wta_rtki == 1
  replace wta_rtk = 5.00  if wta_rtki == 0 // conservative assumption

assert wta_rtk == . if endow == 0 | wantCalInfo == 1 & $gotIt
assert wta_rtk <  . if endow == 1 & wantCalInfo == 0 & $gotIt

/*For subjects initially endowed with info who chose to keep it, calculate
  the WTA to remove the info after all. The 10 options offered to them as an
  alternative to "Keep and see calorie information"(coded as 0) were

  (1 ) Remove calorie information + $0.01
  (2 ) Remove calorie information + $0.25
  (3 ) Remove calorie information + $0.50
  (4 ) Remove calorie information + $0.75
  (5 ) Remove calorie information + $1.00
  (6 ) Remove calorie information + $1.50
  (7 ) Remove calorie information + $2.00
  (8 ) Remove calorie information + $2.50
  (9 ) Remove calorie information + $3.00
  (10) Remove calorie information + $5.00

  A subject who chose 1 for all 10 options is willing to accept not having
  info for some value on interval ]$0,$0.01]. A subject who chose 0 for the
  first option, but 1 for all remaining 9 options is willing to not have info
  for some value on interval $($0.01,$0.25]$. Etc. If we take the midpoint of
  the intervals to be their WTA, and conservatively use $5.00 for the WTA of
  subjects who chose 0 for all 10 options, we get WTA values

  (1 ) 0.5($0.00 + $0.01) = $0.005
  (2 ) 0.5($0.01 + $0.25) = $0.13
  (3 ) 0.5($0.25 + $0.50) = $0.375
  (4 ) 0.5($0.50 + $0.75) = $0.625
  (5 ) 0.5($0.75 + $1.00) = $0.875
  (6 ) 0.5($1.00 + $1.50) = $1.25
  (7 ) 0.5($1.50 + $2.00) = $1.75
  (8 ) 0.5($2.00 + $2.50) = $2.25
  (9 ) 0.5($2.50 + $3.00) = $2.75
  (10) 0.5($3.00 + $5.00) = $4.00
  (11)             $5.00

  Since we ensured in Qualtrics that answers never had 0's following 1's, we
  can calculate the WTA using the following code, which maps the total number
  of 1's to the WTA.                                                          */

egen wta_ktri = rowtotal(wta_keepon_to_remove_*) if $gotIt, missing

gen wta_ktr = .

  replace wta_ktr = 0.005 if wta_ktri == 10
  replace wta_ktr = 0.13  if wta_ktri == 9
  replace wta_ktr = 0.375 if wta_ktri == 8
  replace wta_ktr = 0.625 if wta_ktri == 7
  replace wta_ktr = 0.875 if wta_ktri == 6
  replace wta_ktr = 1.25  if wta_ktri == 5
  replace wta_ktr = 1.75  if wta_ktri == 4
  replace wta_ktr = 2.25  if wta_ktri == 3
  replace wta_ktr = 2.75  if wta_ktri == 2
  replace wta_ktr = 4.00  if wta_ktri == 1
  replace wta_ktr = 5.00  if wta_ktri == 0 // conservative assumption

assert wta_ktr == . if endow == 0 | wantCalInfo == 0 & $gotIt
assert wta_ktr <  . if endow == 1 & wantCalInfo == 1 & $gotIt

/*For subjects initially not endowed with info who chose to add it, calculate
  the WTA to keep the info on after all. The 10 options offered to them as an
  alternative to "Add and see calorie information" (coded as 0) were

  (1 ) Keep calorie information on + $0.01
  (2 ) Keep calorie information on + $0.25
  (3 ) Keep calorie information on + $0.50
  (4 ) Keep calorie information on + $0.75
  (5 ) Keep calorie information on + $1.00
  (6 ) Keep calorie information on + $1.50
  (7 ) Keep calorie information on + $2.00
  (8 ) Keep calorie information on + $2.50
  (9 ) Keep calorie information on + $3.00
  (10) Keep calorie information on + $5.00

  A subject who chose 1 for all 10 options is willing to accept not having
  info for some value on interval ]$0,$0.01]. A subject who chose 0 for the
  first option, but 1 for all remaining 9 options  is willing to not have info
  for some value on interval ]$0.01,$0.25]. Etc. If we take the midpoint of
  the intervals to be their WTA, and conservatively use $5.00 for the WTA of
  subjects who chose 0 for all 10 options, we get WTA values

  (1 ) 0.5($0.00 + $0.01) = $0.005
  (2 ) 0.5($0.01 + $0.25) = $0.13
  (3 ) 0.5($0.25 + $0.50) = $0.375
  (4 ) 0.5($0.50 + $0.75) = $0.625
  (5 ) 0.5($0.75 + $1.00) = $0.875
  (6 ) 0.5($1.00 + $1.50) = $1.25
  (7 ) 0.5($1.50 + $2.00) = $1.75
  (8 ) 0.5($2.00 + $2.50) = $2.25
  (9 ) 0.5($2.50 + $3.00) = $2.75
  (10) 0.5($3.00 + $5.00) = $4.00
  (11) $5.00

  Since we ensured in Qualtrics that answers never had 0's following 1's, we
  can calculate the WTA using the following code, which maps the total number
  of 1's to the WTA.                                                          */

egen wta_atki = rowtotal(wta_add_to_keepoff_*) if $gotIt, missing

gen wta_atk = .

  replace wta_atk = 0.005 if wta_atki == 10
  replace wta_atk = 0.13  if wta_atki == 9
  replace wta_atk = 0.375 if wta_atki == 8
  replace wta_atk = 0.625 if wta_atki == 7
  replace wta_atk = 0.875 if wta_atki == 6
  replace wta_atk = 1.25  if wta_atki == 5
  replace wta_atk = 1.75  if wta_atki == 4
  replace wta_atk = 2.25  if wta_atki == 3
  replace wta_atk = 2.75  if wta_atki == 2
  replace wta_atk = 4.00  if wta_atki == 1
  replace wta_atk = 5.00  if wta_atki == 0 // Conservative assumption

assert wta_atk == . if endow == 1 | wantCalInfo == 0 & $gotIt
assert wta_atk <  . if endow == 0 & wantCalInfo == 1 & $gotIt

/*For subjects initially not endowed with info who chose to keep it on,
  calculate the WTA to add the info after all. The 10 options offered to them
  as an alternative to \Keep calorie information on"(coded as 0) were

  (1 ) Add and see calorie information + $0.01
  (2 ) Add and see calorie information + $0.25
  (3 ) Add and see calorie information + $0.50
  (4 ) Add and see calorie information + $0.75
  (5 ) Add and see calorie information + $1.00
  (6 ) Add and see calorie information + $1.50
  (7 ) Add and see calorie information + $2.00
  (8 ) Add and see calorie information + $2.50
  (9 ) Add and see calorie information + $3.00
  (10) Add and see calorie information + $5.00

  A subject who chose 1 for all 10 options is willing to accept having info
  for some value on interval ]$0,$0.01]. A subject who chose 0 for the first
  option, but 1 for all remaining 9 options is willing to have info for some
  value on interval ]$0.01,$0.25]. Etc. If we take the midpoint of the
  intervals to be their WTA, and conservatively use $5.00 for the WTA of
  subjects who chose 0 for all 10 options, we get WTA values

  (1 ) 0.5($0.00 + $0.01) = $0.005
  (2 ) 0.5($0.01 + $0.25) = $0.13
  (3 ) 0.5($0.25 + $0.50) = $0.375
  (4 ) 0.5($0.50 + $0.75) = $0.625
  (5 ) 0.5($0.75 + $1.00) = $0.875
  (6 ) 0.5($1.00 + $1.50) = $1.25
  (7 ) 0.5($1.50 + $2.00) = $1.75
  (8 ) 0.5($2.00 + $2.50) = $2.25
  (9 ) 0.5($2.50 + $3.00) = $2.75
  (10) 0.5($3.00 + $5.00) = $4.00
  (11)             $5.00

  Since we ensured in Qualtrics that answers never had 0's following 1's, we
  can calculate the WTA using the following code, which maps the total number
  of 1's to the WTA.                                                          */

egen wta_ktai = rowtotal(wta_keepoff_to_add_*) if $gotIt, missing

gen wta_kta = .

  replace wta_kta = 0.005 if wta_ktai == 10
  replace wta_kta = 0.13  if wta_ktai == 9
  replace wta_kta = 0.375 if wta_ktai == 8
  replace wta_kta = 0.625 if wta_ktai == 7
  replace wta_kta = 0.875 if wta_ktai == 6
  replace wta_kta = 1.25  if wta_ktai == 5
  replace wta_kta = 1.75  if wta_ktai == 4
  replace wta_kta = 2.25  if wta_ktai == 3
  replace wta_kta = 2.75  if wta_ktai == 2
  replace wta_kta = 4.00  if wta_ktai == 1
  replace wta_kta = 5.00  if wta_ktai == 0  // Conservative assumption

assert wta_kta == . if endow == 1 | wantCalInfo == 1 & $gotIt
assert wta_kta <  . if endow == 0 & wantCalInfo == 0 & $gotIt

/*Now calculate the value of information implied by the WTA values calculated
  above.

  For subjects initially endowed with info who chose to remove it, the WTA to
  keep the info on after all (wta_remove_to_keepon or wta_rtk for short)
  measures how much they dislike info.

  For subjects initially endowed with info who chose to keep it, the WTA to
  remove the info after all (wta_wta_keepon_to_remove or wta_ktr for short)
  measures how much they like info.

  For subjects initially not endowed with info who chose to add it, the WTA
  to keep the info on after all (wta_add_to_keepoff or wta_atk for short)
  measures how much they like info.

  For subjects initially not endowed with info who chose to keep it on, the
  WTA to add the info after all (wta_wta_keepoff_to_add or wta_kta for short)
  measures how much they dislike info.

  Label the thus calculated value of information valinfocn, with suffix "cn"
  indicating that this measure "conservatively" assigns values -$5 and $5 to
  subjects with extreme values <= -$5 and >= $5.                              */

gen valinfocn = .

  replace valinfocn = -wta_rtk if endow == 1 & wantCalInfo == 0 & $gotIt
  replace valinfocn =  wta_ktr if endow == 1 & wantCalInfo == 1 & $gotIt
  replace valinfocn =  wta_atk if endow == 0 & wantCalInfo == 1 & $gotIt
  replace valinfocn = -wta_kta if endow == 0 & wantCalInfo == 0 & $gotIt

assert valinfocn < . if $gotIt

label var valinfocn "Value of information setting extremes to -5 and 5"


/*To be able to run interval regression on the valinfo data, generate two
  copies, one of which drops left-censored values and one of which drops
  right-censored ones.                                                        */

gen valinfo1 = valinfocn

  replace valinfo1 = . if valinfocn == -5

gen valinfo2 = valinfocn

  replace valinfo2 = . if valinfocn == 5


/*s an alternative way of dealing with extreme values, generate a value
  valinfotr that drops them altogether, with suffix "tr" indicating that the
  values were 'trimmed."                                                      */

gen valinfotr = valinfocn  // Trimming assumption

  replace valinfotr = . if valinfocn == -5 | valinfocn == 5

label var valinfotr "Value of information dropping extremes"

/*   As yet another way of dealing with extreme values, impute them using the
  "triangle" imputation method used by Alcott and Kessler (2015). This method
  involves the following steps:

    See Allcott & Kessler (2019) for more details (see getcleandata_td.pdf)

  Note: I tried doing this for each treatment separately, but that generated
  odd values for treatment nE, because it doesn't have any observations in
  the next-to-extreme bins. The closest alternative was to then spread out
  those bins to -5 and 5, but that yielded very high and low values of
  x (-10 and  7.3). So instead, I ended up doing it for the entire sample at
  once. Since I find that the imputed value on the left is exactly -6 and
  that on the right is 5.952, it seems sensible to round that value up to 6,
  for symmetry.                                                               */


// Generate a variable to hold partially imputed values of information

gen valinfoim = valinfocn

// Get total # of observations

count if $gotIt

local N = r(N)

// Get # of observations in the second bin on the left and the width of the bin

count if valinfocn == -4 & $gotIt

local nil = r(N)

// Get the number of observations in the first bin on the left

count if valinfocn == -5 & $gotIt

local nel = r(N)

// Calculate and assign the imputed value

local xbl = -5 - (2/3)*`nel'/`nil'*(5 - 3)

replace valinfoim = `xbl' if valinfocn == -5  // xbl = -6

// Get # of observations in the next-to-last bin on the right and the width

count if valinfocn == 4 & $gotIt

local nir = r(N)

// Get the number of observations in the extreme bin on the right

count if valinfocn == 5 & $gotIt

local ner = r(N)

// Calculate and assign the imputed value

local xbr = 5 + (2/3)*`ner'/`nir'*(5 - 3)

di `xbr'

  // xbr = 5.952380952380953

replace valinfoim = 6 if valinfocn == 5

*** ORDER VARIABLES ************************************************************

order valinfoim, after(wantCalInfo)

order valinfotr, after(valinfoim)

order valinfocn, after(valinfotr)

order valinfo1, after(valinfocn)

order valinfo2, after(valinfo1)

*** DROP VARIABLES *************************************************************

drop wta_* keepon_or_remove add_or_keep_off

*** SAVE ***********************************************************************

save "$RUTA/results/endowmentEffectInfo.dta", replace

*** END OF FILE ****************************************************************
********************************************************************************
