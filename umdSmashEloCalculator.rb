require "elo"

playerHash = {}

class Player < Elo::Player
	@@numPlayers = 0

	def initialize(name = "")
		super()
		@name = name
	end

	def setNameFromLine(line)
		@name = line[/Name="([^"]*)"/, 1]
	end

	def to_s
		return @name
	end

	def beat(opponent)
		self.wins_from(opponent)
	end

end

def parseMatchLine(line, hash)
	playerOne = line[/Player1="([^"]*)"/ ,1]
	playerTwo = line[/Player2="([^"]*)"/ ,1]
	winner = line[/Winner="([^"]*)"/ ,1]

	#puts "Parsing match between player 1: '#{playerOne}' and player 2: '#{playerTwo}'"

	if winner.eql? "1"
		#player one won
		#puts "\tPlayer 1 won"
		hash[playerOne.to_s].beat(hash[playerTwo.to_s])
	elsif winner.eql? "2"
		#player two won
		#puts "\tPlayer 2 won"
		hash[playerTwo.to_s].beat(hash[playerOne.to_s])
	else
		#error
		abort("Internal error with player victories")
	end

end

puts "LETS GO SG"

=begin
bob = Elo::Player.new
jane = Elo::Player.new

game1 = bob.wins_from(jane);

puts "Bob wins! He now has a rating of #{bob.rating}"
=end

currentFileName = ARGV[0]
puts "currentFile: #{currentFileName}"

if !File.file?(currentFileName)
	abort("Invalid file. Aborting")
end

#state 1 := has not started parsing players
#state 2 := parsing players
#state 3 := has not started parsing match data
#state 4 := parsing match data
#state 5 := done
state = 1
lineNum = 0
puts File.foreach(currentFileName) { |x|

	if state == 1
		#look for '<Players>' tag
		if (x =~ /<Players>/)
			puts "line #{lineNum} matched <Players>!: #{x}"
			state = 2
		end
	elsif state == 2
		#process data and look for '</Players>' tag
		if (x =~ /<\/Players>/)
			puts "line #{lineNum} matched <\/Players!>: #{x}"
			state = 3
		else
			newPlayer = Player.new()
			newPlayer.setNameFromLine(x)
			playerHash[newPlayer.to_s] = newPlayer
		end

	elsif state == 3
		#look for '<Matches>' tag
		if (x =~ /<Matches>/)
			puts "line #{lineNum} matched <Matches>!: #{x}"
			state = 4
		end
	elsif state == 4
		#process data and look for '</Matches>' tag
		if (x =~ /<\/Matches>/)
			puts "line #{lineNum} matched <\/Matches!>: #{x}"
			state = 5
		else
			parseMatchLine(x, playerHash)
		end
	elsif state == 5
		puts "Done"
	else
		#invalid state
		abort("Internal state error. Terminating program")
	end

	lineNum = lineNum + 1
}

puts "Built player Hash:"

playersOrderedByElo = playerHash.values.sort_by {|x| x.rating}.reverse

playersOrderedByElo.each do |x|
	puts "\tplayer #{x} has Elo: #{x.rating}"
end

=begin
playerHash.each do |key, val|
	puts "\tplayer #{val} has an Elo of: #{val.rating}"
end
=end
