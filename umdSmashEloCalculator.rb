require "elo"

puts "LETS GO SG"

bob = Elo::Player.new
jane = Elo::Player.new

game1 = bob.wins_from(jane);

puts "Bob wins! He now has a rating of #{bob.rating}"
