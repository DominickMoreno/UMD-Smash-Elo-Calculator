#Author: popeHat
require "elo"

playerHash = {}

class Player < Elo::Player

	def initialize(name = "", elo = 1000, gamesPlayed = 0)
		super(:games_played => gamesPlayed, :rating => elo)
		@name = name
		@gamesPlayed = gamesPlayed
	end

	def to_s
		return @name
	end

	def self.parsePlayerFromSGLine(line, hash)
		name = line[/Name="([^"]*)"/, 1]
		elo = line[/Elo="([^"]*)"/, 1].to_i
		gamesPlayed = line[/GamesPlayed="([^"]*)"/, 1].to_i

		newPlayer = Player.new(name, elo, gamesPlayed)
		hash[newPlayer.to_s] = newPlayer

		return newPlayer

	end

	def self.parsePlayerFromTournamentLine(line, hash)
		name = line[/Name="([^"]*)"/, 1]

		if !(hash.include? name)
			hash[name.to_s] = Player.new(name)
		end

	end

	def beat(opponent)
		self.wins_from(opponent)
		@gamesPlayed = @gamesPlayed + 1
		opponent.gamesPlayed = opponent.gamesPlayed + 1
	end

	def getRating
		return self.rating
	end

	attr_accessor :gamesPlayed
end

def parseMatchLine(line, hash)
	playerOne = line[/Player1="([^"]*)"/ ,1]
	playerTwo = line[/Player2="([^"]*)"/ ,1]
	winner = line[/Winner="([^"]*)"/ ,1]

	if winner.eql? "1"
		#player one won
		hash[playerOne.to_s].beat(hash[playerTwo.to_s])
	elsif winner.eql? "2"
		#player two won
		hash[playerTwo.to_s].beat(hash[playerOne.to_s])
	else
		#error
		abort("Internal error with player victories. Aborting")
	end

end

def dateValid?(dateStr)
	monthStr = dateStr[/^(\d+)/ ,1]
	dayStr = dateStr[/^\d+-(\d+)/ ,1]
	yearStr = dateStr[/^\d+-\d+-(\d+)/ ,1]

	month = monthStr.to_i
	day = dayStr.to_i
	year = yearStr.to_i

	if !(month >= 1 && month <= 12)
		puts "That's not a real month, moron"
		return false
	elsif !(day >= 1 && day <= 31)
		puts "that's not a real day, nincompoop"
		return false
	elsif !(year >= 2000 && year <= 2099)
		puts "the year is 20xx... idiot"
		return false
	end

	return true

end

if ARGV.size < 2
	puts "Error using Elo calculator."
	puts "Must provide the name of the intermediate *.sg file that contains all" +
			" of the intermediate Elo data for the semester, the date, and the" +
			" current tournament's data."
	puts "For example: "
	puts "\t'ruby umdSmashEloCalculator.rb 9-18-2015.sg 9-25-2015 9-25-2015-challonge-results.bcn'"
	puts "OR"
	puts "To start a new semester, provide the date then the current tournament's data."
	puts "For example: "
	puts "\t'ruby umdSmashEloCalculator.rb 9-18-2015 9-18-2015-challonge-results.bcn'"

	abort("Terminating program")
end

hasExistingTournamentData = false

if ARGV.size == 2
	#make new one
	puts "No previous data provided. Using only tournament data given for this week."
	dateStr = ARGV[0]

	if !dateValid?(dateStr)
		abort("Improperly formatted date. Please use: '{month}-{day}-{20xx}'. Aborting")
	end

	currentFileName = ARGV[1]

	if !File.file?(currentFileName)
		abort("Invalid tournament data file. Aborting")
	end

elsif ARGV.size == 3
	#add to existing
	puts "Using previous semester data."
	semesterDataFileName = ARGV[0]

	if !File.file?(semesterDataFileName)
		abort("Invalid semester data file. Aborting")
	end

	dateStr = ARGV[1]

	if !dateValid?(dateStr)
		abort("Improperly formatted date. Please use: '{month}-{day}-{20xx}'. Aborting")
	end

	currentFileName = ARGV[2]

	if !File.file?(currentFileName)
		abort("Invalid tournament data file. Aborting")
	end

	hasExistingTournamentData = true
end

puts "Adding data from most recent tournament held on #{dateStr}"
puts "\tGetting most recent tournament data from file: #{currentFileName}"

if hasExistingTournamentData
	#open/read/parse that file
	puts "Loading semester data..."
	File.foreach(semesterDataFileName) { |line|
		newPlayer = Player.parsePlayerFromSGLine(line, playerHash)
	}
	puts "\tdone"
end


#state 1 := has not started parsing players
#state 2 := parsing players
#state 3 := has not started parsing match data
#state 4 := parsing match data
#state 5 := done
state = 1
lineNum = 0

puts "parsing data from this tournament..."
File.foreach(currentFileName) { |x|

	if state == 1
		#look for '<Players>' tag
		if (x =~ /<Players>/)
			state = 2
		end
	elsif state == 2
		#process data and look for '</Players>' tag
		if (x =~ /<\/Players>/)
			state = 3
		else
			newPlayer = Player.parsePlayerFromTournamentLine(x, playerHash)
		end

	elsif state == 3
		#look for '<Matches>' tag
		if (x =~ /<Matches>/)
			state = 4
		end
	elsif state == 4
		#process data and look for '</Matches>' tag
		if (x =~ /<\/Matches>/)
			state = 5
		else
			parseMatchLine(x, playerHash)
		end
	elsif state == 5
		#noop
	else
		#invalid state
		abort("Internal state error. Terminating program")
	end

	lineNum = lineNum + 1
}
puts "\tdone"

playersOrderedByElo = playerHash.values.sort_by {|x| x.rating}.reverse

puts "writing data to new semester file..."
outFileName = dateStr + ".sg"
outFile = File.new(outFileName, "w")
playersOrderedByElo.each do |x|
	outFile.puts("Name=\"#{x}\", Elo=\"#{x.rating}\", GamesPlayed=\"#{x.gamesPlayed}\"")
end
outFile.close

puts "\tdone\nScript complete. Most recent Elo rankings available in file '#{outFileName}'"
