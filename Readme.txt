Author: Dominick Moreno
This project is available for use by anyone for any purpose with or without attribution.

This script and accompanying files are used by the University of Maryland's Super Smash
Bros club in order to track participants in the weekly Melee tournaments' Elo. It uses
the Ruby Elo Api found here:

	https://github.com/iain/elo

This project expects tournament data to be in a fairly specific format. You can see the
folder "Data/Melee_Season2.bcn" for the format used - although less strict ones should
be theoretically possible. Typically this data will be collected from the Challonge 
trawling program, which will output into the appropriate XML format. 

It will output files whose names will be the date of the most recent tournament data
they contain, and will end with the file extension ".sg". So for example if the most
recently held tournament was on September 25th, 2015, the most up to date Elo ranking
file will be named "9-25-2015.sg".

There are two ways to use this script:

	1. You have no prior data - only a file containing the data from the most recent
tournament

	2. You have prior data AND the file containing data from the most recent 
tournament

To run the script in the first case, you would do the following (assuming the date
was 9/18/2015 and the tournament data file was named "tourneyData.bcn"):

	"ruby umdSmashEloCalculator.rb 9-18-2015 tourneyData.bcn"
		>outputs file "9-18-2015.sg"

To run the script in the second case, you would do the following (assuming
the date was 9/25/2015, the tourney data file was named "tourneyData.bcn", and
the previous week's .sg file was in the subfolder "Data/9-18-2015.sg"):

	"ruby umdSmashEloCalculator.rb Data/9-18-2015.sg 9-25-2015 tourneyData.bcn"
		>outputs file "9-25-2015.sg"

Improroper use of dates or files will terminate the program with an error message.
If something is going particularly wrong e-mail myself at:

	DominickMoreno92@gmail.com

Or contact me on facebook.

Further work on this script might include:
	* Cleaner comments
	* More robust error handling/string parsing
	* Tracking of games won/lost (instead of just Elo + games played)
	* Tracking of characters/alts
	* Interfacing with an actual database such as SQL instead of formatted text files
	* Hosting data online
	* Other??? - Suggest something!
