/*******************************************************************************
Project:      Expecting to get it: An Endowment Effect for Information

Authors:      TabareCapitan.com
              klaas@uwyo.edu

Description:  Clean raw .dta data.

Created: 20190217 | Last modified:20200719
*******************************************************************************/
version 14.2

*** LOAD DATA ******************************************************************

use "$RUTA/temp/data/raw.dta", clear

quietly destring, replace

*** TAG VALID OBSERVATIONS *****************************************************

gen valid = 1

  // vegetarian or vegan
  replace valid = 0 if screen_diet == 1

  // participated in previous experiment
  replace valid = 0 if screen_exp2018 == 1

  // did not intend to eat the dessert
  replace valid = 0 if intend == 2

  order valid, first

*** NEW VARIABLES **************************************************************

* IDENTIFY TREATMENTS ----------------------------------------------------------

gen nN = prime == 0 & endow == 0

  order nN, after(valid)

gen nE = prime == 0 & endow == 1

  order nE, after(nN)

gen pN = prime == 1 & endow == 0

  order pN, after(nE)

gen pE = prime == 1 & endow == 1

  order pE, after(pN)

gen treatment = ""

  replace treatment = "nN" if nN == 1
  replace treatment = "nE" if nE == 1
  replace treatment = "pN" if pN == 1
  replace treatment = "pE" if pE == 1

  order treatment, after(valid)

* INFORMATION CHOICE -----------------------------------------------------------

/*
  If subjects where shown info (endow == 1), then the keepon_or_remove
  variable is 2 if they chose to keep it, and 1 if they chose to have it
  removed.
  If subjects were not shown info (endow == 0), then the add_or_keep_off
  variable is 1 if they chose to add it, and 2 if they chose to have it
  removed.
*/

gen wantCalInfo = .

  replace wantCalInfo = 1 if endow == 1 & keepon_or_remove == 2
  replace wantCalInfo = 0 if endow == 1 & keepon_or_remove == 1
  replace wantCalInfo = 1 if endow == 0 & add_or_keep_off  == 1
  replace wantCalInfo = 0 if endow == 0 & add_or_keep_off  == 2

  order wantCalInfo, after(pE)

* PREVIOUS KNOWLEDGE OF THE EXPERIMENT -----------------------------------------

/*   Qualtrics codes the "Please let us know if before you arrived here today,
  you heard anything about the type of questions we asked you in this study
  or about the kind of desserts we were using." variable prevknow as

    I heard nothing = 1
    I heard some    = 2
    I heard a lot   = 3

  If subjects chose "I heard some" or "I heard a lot," a follow-up question
  "Please let us know  specifically if you heard anything about the type of
  questions we asked" was asked, and the answer, stored in variable prevques,
  coded as

    I heard nothing about the questions = 1
    I heard some about the questions    = 2
    I heard a lot about the questions   = 3

  The display logic for then asking them "Could you please describe exactly
  what you heard before coming in?" was screwed up (we should do display
  logic only in the Survey Flow next time!), so that people who answered
  "I heard nothing" on the preknow question also got to answer it. Here's
  the list of answers for the 9 participants who selected 2 or 3 in
  "prevques":

  1- Linda
  2- they were about calorie content and risk averseness
  3- choose each option that gives you more money
  4- Just that there was a little survey to answer and you get money and cake
  5- About the survey of habits
  6- They ask about choosing between options
  7- I heard that it involved calories and choices.
  8- I only heard that it was an economic decision making study.
  9- what kind of survey this going to be. for example if you choose
    thailand then do you want to stick with it or prefer vietnam with
    pocket money

  We tag the answers that involve calories as people who might have too much
  previous knowledge of what the experiment was about: 2 and 7.        */

gen _tagKnewAboutExp = 0

  replace _tagKnewAboutExp  = 1 if                                              ///
    prevques_desc == "they were about calorie content and risk averseness"

  replace _tagKnewAboutExp  = 1 if                                              ///
    prevques_desc == "I heard that it involved calories and choices."

  order _tagKnewAboutExp, last

*** RECODE VARIABLES ***********************************************************

* TESTS OF UNDERSTANDING -------------------------------------------------------

gen _testA = ( ex5a == 6 ) if !missing(ex5a)

gen _testB = ( ex5b == 9 ) if !missing(ex5b)

gen _testC = confused8 if !missing(confused8)                                   // NOT SURE

  order _test*, last

/* HUNGER LEVEL ----------------------------------------------------------------

  Qualtrics codes the "How hungry are you right now?" variable hungry as

    Not hungry at all = 3
    Somewhat hungry   = 4
    Hungry            = 2
    Very Hungry       = 1

  Change that to:

    Not hungry at all = 0
    Somewhat hungry   = 1
    Hungry            = 2
    Very Hungry       = 3
*/

recode hungry (3=0) (4=1) (1=3)

/* FEMALE ----------------------------------------------------------------------

  Qualtrics codes the "What is your gender?" variable gender as

    Male   = 1
    Female = 2

  Change that to a female dummy with

    Male   = 0
    Female = 1
*/

rename gender female

recode female (1=0) (2=1)

/* AGE -------------------------------------------------------------------------

  Qualtrics codes the \What is your age?" variable age as

    18         = 1
    19         = 2
    ...        ...
    79         = 62
    80 or more = 63

  No one was 80 or more, so just recode this by adding 17.
*/

replace age = age + 17 if !missing(age)

/* EDUCATION -------------------------------------------------------------------

  Qualtrics codes the "What is your highest level of education?" variable
  education as

    Less than high school = ?
    High school           = 2
    Professional degree   = 6
    Some college          = 3
    College degree        = 4

  (The question mark indicates that nobody selected "Less than high school")

  Change this to

    Less than high school = ?
    High school           = 1
    Professional degree   = 2
    Some college          = 3
    College degree        = 4

  and generate a collegeDegree dummy equal to 1 if the subject has a college
  degree.
*/

recode education (2=1) (6=2)

gen collegeDegree = (education == 4)

  order collegeDegree, after(education)

/* RISK PREFERENCES ------------------------------------------------------------

  Qualtrics codes the "Please select the gamble below that you would choose
  to participate in" variable riskpref as

    Gamble 1: low outcome: $28, high outcome: $28 = 1
    Gamble 2: low outcome: $24, high outcome: $36 = 2
    Gamble 3: low outcome: $20, high outcome: $44 = 3
    Gamble 4: low outcome: $16, high outcome: $52 = 4
    Gamble 5: low outcome: $12, high outcome: $60 = 5
    Gamble 6: low outcome: $2,  high outcome: $70 = 6

  For now, let's stick with treating this as is as a Likert scale, but let's
  also create dummies for each item, for the later Hosmer et al. (2013)
  analysis Step 1.
*/

rename riskpref riskPref

tab riskPref, generate(riskPref_)

  order riskPref_*, after(riskPref)

/* EATING SELF-CONTROL ---------------------------------------------------------

  The foodsc_[1-10] variables map as follows to the Haws et. al eating
  self-control scale, with stars indicating reverse coding.

    foodsc_1     I am good at resisting tempting food.
    foodsc_2*    I have a hard time breaking bad eating habits.
    foodsc_3*    I eat inappropriate things.
    foodsc_4*    I eat certain things that are bad for my health, if they
                 are delicious.
    foodsc_5     I refuse to overindulge on foods that are bad for me.
    foodsc_6     People would say that I have iron self-discipline with my
                 eating.
    foodsc_7     I am able to work effectively toward long-term health goals.
    foodsc_8*    Sometimes I can't stop myself from eating something, even if
                 I know it is bad for me.
    foodsc_9*    I often eat without thinking through the health
                 consequences.
    foodsc_10*   I wish I had more self-discipline in food consumption.

  The original coding is

    Very much disagree         = 1
    Disagree                   = 2
    Neither agree nor disagree = 3
    Agree                      = 4
    Very much agree            = 5

  so to reverse-code the starred statements 2, 3, 4, 8, 9, and 10 we need to
  do the following:
*/

recode foodsc_2 foodsc_3 foodsc_4 foodsc_8 foodsc_9 foodsc_10                   ///
  (1=5) (2=4) (4=2) (5=1)

/*  We can then generate an index of eating self-control, esc, by summing over
    the statements:
*/

egen esc = rowtotal(foodsc_*)

  order esc, before(foodsc_1)

/* DISCOUNTING -----------------------------------------------------------------

  The answer to question "Suppose someone was going to pay you $450 in one
  month. He/she oFFers to pay a lower amount today. What amount today would
  make you just as happy as receiving $450 in one month?" is saved in
  variable q147 and the answer to question "Suppose someone was going to pay
  you $450 in 13 months. He/she offers to pay a lower amount in 12 months.
  What amount in 12 months would make you just as happy as receiving $450 in
  13 months?" in variable q148.

  Calculate the implied beta and delta hyperbolic-discounting coefficients as
  follows:   See Klaas' getcleandata_td.pdf
*/

rename q147 x1

rename q148 x2

gen delta = x2/450 if !missing(x2)

  order delta, after(x1)

gen beta = x1/x2 if x2 > 0 & !missing(x2) & !missing(x1)

  order beta, after(x2)

/* CALORIE INFORMATION PREFERENCES ---------------------------------------------

  Qualtrics codes the "At what venues do you want to know about calories in
  the food (including sweets and snacks) served? Please mark all that apply."
  variable venues as

    When I go to a coffee shop                   = 1
    When I go to a fast food restaurant          = 2
    When I go to a diner                         = 3
    When I go to a fancy restaurant              = 4
    When I buy something to eat at a gas station = 5
    When I eat a meal cooked at home             = 6
    I never want to know about calories          = 7

  Subjects could make multiple choices, though, so the answer is a
  comma-separated list. Create separate dummies for each answer.
*/

mark vknwcof if regexm(venues,"1")

  order vknwcof, before(venues)

mark vknwfas if regexm(venues,"2")

  order vknwfas, before(venues)

mark vknwdin if regexm(venues,"3")

  order vknwdin, before(venues)

mark vknwres if regexm(venues,"4")

  order vknwres, before(venues)

mark vknwgas if regexm(venues,"5")

  order vknwgas, before(venues)

mark vknwhom if regexm(venues,"6")

  order vknwhom, before(venues)

mark nevvknw if venues == "7"

  order nevvknw, before(venues)

/*   Also create a variable nvenues counting the number of venues at which the
  subject wants to know.
*/

egen nvenues = rowtotal(vknw*)

  order nvenues, before(venues)

/* Qualtrics codes the "Do you think most people would like to know the
   calorie content in food they eat away from home?" variable othknow as

    Yes = 1
    No  = 2

  Recode this as

    Yes = 1
    No  = 0
*/

recode othknow (2=0)

/* Qualtrics codes the "When do you want to know about calories in meals?"
  variable youknow as

    Always                  = 1
    It depends              = 2
    Only when I'm on a diet = 3
    Never                   = 4

  If subjects chose "It depends," a follow-up question "When do you want
  to know about calories in meals? Please mark all that apply." was
  asked, and the answer, stored in variable youknow2, coded as

    When I go out to eat to celebrate something special ...           = 1
    When I go to a restaurant/coffee shop where I eat frequently      = 2
    When I go to a restaurant/coffee shop where I otherwise never eat = 3
    When I go to a restaurant/coffee shop to treat myself ...         = 4
    When someone else takes me out to a restaurant/coffee shop        = 5

  Subjects could make multiple choices for that second question, so the
  answer is a comma-separated list. Create separate dummies for each answer.

  (The display logic for follow-up question "For what meal do you want to
  know about calories when you go out?" was unfortunately screwed up, so it
  is empty for all subjects.)
*/

mark alwtknw if youknow == 1

  order alwtknw, before(youknow)

mark tknwcel if youknow == 2 & regexm(youknow2,"1")

  order tknwcel, before(youknow)

mark tknwfrq if youknow == 2 & regexm(youknow2,"2")

  order tknwfrq, before(youknow)

mark tknwotn if youknow == 2 & regexm(youknow2,"3")

  order tknwotn, before(youknow)

mark tknwtrt if youknow == 2 & regexm(youknow2,"4")

  order tknwtrt, before(youknow)

mark tknwels if youknow == 2 & regexm(youknow2,"5")

  order tknwels, before(youknow)

mark ondtknw if youknow == 3

  order ondtknw, before(youknow)

mark nevtknw if youknow == 4

  order nevtknw, before(youknow)

/* Also create a variable noccas counting the number of occasions at which the
  subject wants to know.
*/

egen noccas = rowtotal(tknw*)

  order noccas, before(youknow)

/*Qualtrics codes the 'Sometimes people do not want to know the calorie
  content of their meals when eating out. What do you think is the most
  common reason people avoid calorie information when eating at a
  restaurant/coffee shop?" variable avoid (which we accidentally didn't label
  with "Mark all that apply") as

    They don't want to think of calories when they eat out = 1
    Calorie information would not matter ... anyway        = 2
    They would feel guilty ...                             = 11
    They know the calorie content anyway                   = 4
    They do not know how to interpret calorie information  = 5
    I do not know                                          = 6
    Other (please specify)                                 = 7

  Generate separate dummies for each reason:
*/

mark reasthk if regexm(avoid,"1")

  order reasthk, before(avoid)

mark reasmat if regexm(avoid,"2")

  order reasmat, before(avoid)

mark reasgui if regexm(avoid,"11")

  order reasgui, before(avoid)

mark reasknw if regexm(avoid,"4")

  order reasknw, before(avoid)

mark reasint if regexm(avoid,"5")

  order reasint, before(avoid)

mark dnkreas if regexm(avoid,"6")

  order dnkreas, before(avoid)

mark reasoth if regexm(avoid,"7")

  order reasoth, before(avoid)

/* Also create a variable nreasons counting the number of reasons given by the
  subject
*/

egen nreasons = rowtotal(reas*)

  order nreasons, before(avoid)

/* IMPORTANCE OF HEALTH --------------------------------------------------------

  Qualtrics codes the "How important is it to you that the food you eat is
  healthy?" variable important_1 as

    Not at all important   = 5
    Slightly important     = 4
    Moderately important   = 3
    Very important         = 2
    Extremely important    = 1

  Change this to a new variable healthImportant with coding

    Not at all important   = 1
    Slightly important     = 2
    Moderately important   = 2
    Very important         = 3
    Extremely important    = 3
*/

rename important_1 healthImportant

recode healthImportant (1=3) (2=3) (3=2) (4=2) (5=1)

/* IMPORTANCE OF EXERCISE ------------------------------------------------------

  Qualtrics codes the "How important is it to you to exercise regularly?"
  variable important_2 as

    Not at all important   = 5
    Slightly important     = 4
    Moderately important   = 3
    Very important         = 2
    Extremely important    = 1

  Change this to a new variable exerciseImportant with coding

    Not at all important   = 1
    Slightly important     = 2
    Moderately important   = 2
    Very important         = 3
    Extremely important    = 3
*/

rename important_2 exerciseImportant

recode exerciseImportant (1=3) (2=3) (3=2) (4=2) (5=1)

/* IMPORTANCE OF WEIGHT --------------------------------------------------------

  Qualtrics codes the "How important is it to you to be of a healthy body
  weight?" variable important_3 as

    Not at all important   = 5
    Slightly important     = 4
    Moderately important   = 3
    Very important         = 2
    Extremely important    = 1

  Change this to a new variable weightImportant with coding

    Not at all important   = 1
    Slightly important     = 2
    Moderately important   = 2
    Very important         = 3
    Extremely important    = 3
*/

rename important_3 weightImportant

recode weightImportant (1=3) (2=3) (3=2) (4=2) (5=1)

/* PREVIOUS EXPOSURE TO CALORIE INFORMATION -----------------------------------

  Qualtrics codes the "Do you recall if [restaurants, etc., that you've been
  to over the past 12 months] displayed information about calories in their
  food items ..." variable prevexp as

    I do not recall ever seeing calories displayed ... = 1
    I recall rarely seeing calories displayed ...      = 2
    I recall sometimes seeing calories displayed ...   = 3
    I recall often seeing calories displayed ...       = 4
    I recall always seeing calories displayed ...      = 5

  Let's stick with treating this as is as a Likert scale, but let's also
  create dummies for each item, for the later Hosmer et al. (2013) analysis
  Step 1.
*/

rename prevexp prevExp

tab prevExp, generate(prevExp_)

  order prevExp_*, after(prevExp)

/* Qualtrics codes the "On average, how often have you eaten at chain
  restaurants [during the past 12 months]?" variable chain and the
  "On average, how often have you eaten at coffee shops [during the past 12
  months]?" variable coffee as

    Every day              = 1
    3-5 times a week       = 2
    Once a week            = 3
    2-3 times a month      = 4
    Once a month           = 5
    Less than once a month = 6

  It makes more sense to reverse code these, so that higher numbers reflect a
  higher likelihood of exposure and reduce the categories to three to better
  adjust for measurement error:
*/

recode chain (1=3) (2=3) (3=2) (4=2) (5=1) (6=1)

recode coffee (1=3) (2=3) (3=2) (4=2) (5=1) (6=1)

/* Drop coffee because it is not clear what people understood. For example,
  did people count getting a coffee in the union?
*/

drop coffee

/* Also create dummies for each Likert-scale item, for the later
  Hosmer et al. (2013) analysis Step 1.
*/

tab chain, generate(chain_)

  order chain_*, after(chain)

/* KNOWLEDGE ABOUT CALORIES ----------------------------------------------------

  Qualtrics codes the "Approximately how many calories should a moderately
  active 30-40 year old man eat per day to maintain a healthy body weight?"
  variable shouldeat as

    Around 50 calories     = ?
    Around 500 calories    = 4
    Around 1,500 calories  = 1
    Around 2,500 calories  = 2
    Around 4,000 calories  = 3
    Around 6,000 calories  = 5
    Around 10,000 calories = 6

  Recode this more sensibly as follows:

    Around 50 calories     = 1
    Around 500 calories    = 2
    Around 1,500 calories  = 3
    Around 2,500 calories  = 4
    Around 4,000 calories  = 5
    Around 6,000 calories  = 6
    Around 10,000 calories = 7
*/

rename shouldeat shouldEat

recode shouldEat (4=2) (1=3) (2=4) (3=5) (5=6) (6=7)

/* Also create dummies for each Likert-scale item, for the later
  Hosmer et al. (2013) analysis Step 1.
*/

tab shouldEat, generate(shouldEat_)

  order shouldEat_*, after(shouldEat)

/* Create a dummy "knowledge" for the correct answer (2500 calories) to
  distinguish subjects who knew the right answer from subjects who didn't.
*/

gen calNeedsKnowledge = (shouldEat == 4)

  order calNeedsKnowledge, before(shouldEat)

/* HEALTH STATUS ---------------------------------------------------------------

  Qualtrics codes

  - the "I am in excellent health" variable health_1,
  - the "I would benefit from eating healthier" variable health_2,
  - the 'I wish I could make healthier food choices at home" variable
  health_3, and
  - the "I wish I could make healthier food choices when eating out"
  variable health_4 as

    Very much disagree         = 1
    Disagree                   = 2
    Neither agree nor disagree = 3
    Agree                      = 4
    Very much agree            = 5

  Change to

    Very much disagree         = -1
    Disagree                   = -1
    Neither agree nor disagree =  0
    Agree                      =  1
    Very much agree            =  1
  */

recode health_1 health_2 health_3 health_4 (5=1) (4=1) (3=0) (2=-1) (1=-1)

rename health_1 healthStatus

rename health_2 benefitEatHealthier

rename health_3 wishEatBetterHome

rename health_4 wishEatBetterOut

/* Create dummy for each if there is agreement with the statement */

local statements "healthStatus benefitEatHealthier wishEatBetterHome wishEatBetterOut"

foreach x of local statements {

  gen d_`x' = (`x' > 0) if !missing(`x')

    order d_`x', after(`x')
}


/*  Also create dummies for each Likert-scale item, for the later
  Hosmer et al. (2013) analysis Step 1.
*/


tab healthStatus, generate(healthStatus_)

  order healthStatus_*, after(healthStatus)

tab benefitEatHealthier, generate(benefitEatHealthier_)

  order benefitEatHealthier_*, after(benefitEatHealthier)

tab wishEatBetterHome, generate(wishEatBetterHome_)

  order wishEatBetterHome_*, after(wishEatBetterHome)

tab wishEatBetterOut, generate(wishEatBetterOut_)

  order wishEatBetterOut_*, after(wishEatBetterOut)

/* BODY WEIGHT -----------------------------------------------------------------

  Qualtrics codes the "What best describes your body weight?" variable
  weightDescr as

    I am underweight   = 7
    I am normal weight = 4
    I am overweight    = 1
    I am obese         = 2
    I do not know      = 3

  Recode this more sensibly as follows:

    I am underweight   = 1
    I am normal weight = 2
    I am overweight    = 3
    I am obese         = 4
    I do not know      = .a

  Also generate separate dummies for each description:
*/

rename weight_desc weightDesc

recode weightDesc (7=1) (4=2) (1=3) (2=4) (3=.a)


tab weightDesc, gen(weightDesc_)

  order weightDesc_*, after(weightDesc)

  rename weightDesc_1 underWeight
  rename weightDesc_2 normal
  rename weightDesc_3 overWeight
  rename weightDesc_4 obese

/* HEIGHT, WEIGHT, AND BMI -----------------------------------------------------

  Rename the height in feet and inches (height_1 and height_2) variables and
  calculate BMI from them combined with the weight in pounds (weight_pounds)
  variable, using the formula bmi = kg/m^2                  */

rename height_1 height_ft

rename height_2 height_in

rename weight_pounds weight_lb

gen height_m = height_ft*0.3048 + height_in*0.0254

gen weight_kg = weight_lb*0.45359237

gen bmi = weight_kg/(height_m^2)

  order bmi, before(weightDesc)

/* EXPENDITURE -----------------------------------------------------------------

  Qualtrics codes the "In a typical month, how much do you spend on food,
  housing, transportation, utilities, and other items?" variable expenditure
  as

    $400   - less   = 1
    $401   - $600   = 2
    $601   - $800   = 3
    $801   - $1,000 = 4
    $1,001 - $1,200 = 5
    $1,201 - $1,400 = 6
    $1,401 - $1,600 = 7
    $1,601 - $1,800 = 8
    $1,801 - $2,000 = 9
    $2,000 - more   = 10

    I'd rather not say = 11

  Rename this variable exp_cat and use it to calculate a different
  expenditure variable by using the midpoint of the intervals
  (picking $2,100 for the top one). Recode "I'd rather not say" as ".a".
  For the variable exp_cat, recode 11 to ".a".
*/

rename expenditure exp_cat

replace exp_cat = .a if exp_cat == 11

gen expenditure = .

  replace expenditure = 200  if exp_cat == 1
  replace expenditure = 500  if exp_cat == 2
  replace expenditure = 700  if exp_cat == 3
  replace expenditure = 900  if exp_cat == 4
  replace expenditure = 1100 if exp_cat == 5
  replace expenditure = 1300 if exp_cat == 6
  replace expenditure = 1500 if exp_cat == 7
  replace expenditure = 1700 if exp_cat == 8
  replace expenditure = 1900 if exp_cat == 9
  replace expenditure = 2100 if exp_cat == 10
  replace expenditure = .a   if exp_cat == .a

    order expenditure, after(exp_cat)

/* INCOME ----------------------------------------------------------------------

  Qualtrics codes the 'What is your individual annual, pre-tax income?"
  variable income as

    $10,000 -  less      = 1
    $10,001 -  $12,500   = 2
    $12,501 -  $15,000   = 3
    $15,001 -  $17,500   = 4
    $17,501 -  $20,000   = 5
    $20,001 -  $25,000   = 6
    $25,001 -  $30,000   = 7
    $30,001 -  $50,000   = 8
    $50,001 -  $70,000   = 9
    $70,001 -  $100,000  = ?
    $100,000 - more      = ?
    I'd rather not say   = 10

  Rename this variable inc_cat and use it to calculate a different income
  variable by using the midpoint of the intervals. Recode
  "I'd rather not say" as ".a". For the variable inc_cat, recode 11 to ".a".
*/

rename income inc_cat

replace inc_cat = .a if inc_cat == 10

gen income = .

  replace income = 5000  if inc_cat == 1
  replace income = 11250 if inc_cat == 2
  replace income = 13750 if inc_cat == 3
  replace income = 16250 if inc_cat == 4
  replace income = 18750 if inc_cat == 5
  replace income = 22500 if inc_cat == 6
  replace income = 27500 if inc_cat == 7
  replace income = 40000 if inc_cat == 8
  replace income = 60000 if inc_cat == 9
  replace income = .a    if inc_cat == .a

  order income, after(inc_cat)

*** RENAME VARIABLES ***********************************************************

local meta = "startdate enddate durationinseconds recordeddate"

foreach metaVar of local meta {

  rename `metaVar' _`metaVar'

  order _`metaVar', last
}

local timing "time_rtk_firstclick time_rtk_lastclick time_rtk_pagesubmit time_rtk_clickcount time_ktr_firstclick time_ktr_lastclick time_ktr_pagesubmit time_ktr_clickcount time_atk_firstclick time_atk_lastclick time_atk_pagesubmit time_atk_clickcount time_kta_firstclick time_kta_lastclick time_kta_pagesubmit time_kta_clickcount"

foreach time of local timing {

  rename `time' __`time'

  order __`time', last
}

rename q_totalduration __q_totalduration

  order __q_totalduration, last

*** FIX TIME AND DATE FORMAT *************************************************** // PENDING

*** DROP VARIABLES *************************************************************

#delimit ;

drop   status
    ipaddress
    progress
    responseid
    recipientfirstname
    recipientlastname
    recipientemail
    externalreference
    locationlatitude
    locationlongitude
    distributionchannel
    userlanguage
    finished

    id1 id2
    screen_diet
    screen_exp2018
    intend

    prevknow
    prevques
    prevques_desc

    ex5a
    ex5b

    x1 x2

    venues

    youknow
    youknow2
    whatmeal

    avoid
    avoid_7_text

    height_ft
    height_in
    weight_lb
    height_m
    weight_kg

    ex1 - wta4_6
    ex8 - wta8_6

    priming*

    do_* *_do

    oath

    parse*

    confused*

    row*

    cmon*

    dessert*

    descal*

    ses*

    nc*

    screened_out - ccod
    ;

#delimit cr

*** ORDER VARIABLES ************************************************************

order prime, after(valid)

order endow, after(prime)

*** SAVE DATA ******************************************************************

save "$RUTA/temp/data/clean.dta", replace

*** END OF FILE ****************************************************************
********************************************************************************
