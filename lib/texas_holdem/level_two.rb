require 'csv'

class LevelTwo
  attr_reader :level_goal, :level_start, :big_blind, :small_blind

  def initialize
  	@level_goal = 160000
  	@level_start = 40000
  	@big_blind = 2000
  	@small_blind = 1000 
	@two_players = Hash.new
	@three_players = Hash.new
	@four_players = Hash.new
	CSV.foreach('../lib/assets/winning_perc_sheet.csv') do |row|
	  @two_players[row[0]] = row[1]
	  @three_players[row[0]] = row[2]
      @four_players[row[0]] = row[3]
    end
  end

  def get_bet cards, players
	odds = get_odds(cards, players)
	if odds > 75
	  ["call", "check", "8000", "10000", "14000", "16000", "20000", "40000", "60000"].sample
	elsif odds > 60
	  ["call", "check", "4000", "6000", "8000", "10000"].sample
	elsif odds > 45
	  ["call", "check", "2000", "4000"].sample
	elsif odds > 30
	  ["call", "check"].sample
	else
	  ["fold", "check", "call"].sample
    end
  end

  def get_odds cards, players
  	cards_string = cards_to_string(cards)
	odds = get_perc_value(cards_string, players)
  end
   
  private

  def get_perc_value cards, players 
	if players == 2
	  @two_players[cards].match(/[0-9]*/).to_s.to_i
	elsif players == 3
	  (@three_players[cards]*1.25).match(/[0-9]*/).to_s.to_i
	else
	  (@four_players[cards]*1.5).match(/[0-9]*/).to_s.to_i
    end
  end
 
  def cards_to_string cards
  	cards_string = ""
  	if cards[0].face_value > cards[1].face_value
  	  cards_string += cards[0].face_display + cards[1].face_display
  	else
  	  cards_string += cards[1].face_display + cards[0].face_display
  	end

  	if cards_string[0] == cards_string[1]
  	  return cards_string
  	elsif cards[0].suit_value == cards[1].suit_value
  	  cards_string += "s"
  	else
  	  cards_string += "o"
  	end
  end
end
