Author: Dominick Moreno
This project is available for use by anyone for any purpose with or without attribution.

This script and accompanying files are used by the University of Maryland's Super Smash
Bros club in order to track participants in the weekly Melee tournaments' Elo. It uses
the Ruby Elo Api found here:

	https://github.com/iain/elo

In its current state this project calculates Elo based on one and only one tournament.
That is, every player starts with the same Elo (1000) at the start of every tournament.
Obviously this is not how we want to use this script, particularly since UMD is 
interested in creating their own Power Ranking (PR). 

This project's next step is to write all of this data to an intermediate file, most
likely a CSV, and have it be able to load that file so not every player starts with
a fresh Elo. It will then update that file with the most recent smash fest data
