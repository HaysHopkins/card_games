require 'csv'

class LevelTwo

  def initialize
	@two_players = Hash.new
	@three_players = Hash.new
	@four_players = Hash.new
	CSV.foreach('../assets/winning_perc_sheet.csv') do |row|
	  @two_players[row[0]] = row[1]
	  @three_players[row[0]] = row[2]
      @four_players[row[0]] = row[3]
    end
    puts @four_players
  end

  def get_bet cards, players
	cards_string = cards_to_string(cards)
	odds = get_odds(cards_string, players)
	if odds > 90
	  ["call", "check", "200", "250", "300", "350"].sample()
	elsif odds > 75
	  ["call", "check", "100", "150"].sample()
	elsif odds > 60
	  ["call", "check", "50", "75"].sample()
	elsif odds > 45
	  ["call", "check"].sample()
	else
	  ["fold", "check"].sample
    end
  end

  private

  def get_odds cards, players 
	if players == 2
	  @two_players[cards]
	elsif players == 3
	  @three_players[cards]*1.25
	else
	  @four_players[cards]*1.5
    end
  end

  def cards_to_string cards
  	cards_string = cards.each do |card|
      card.to_s[0]  
  	end
  	if suit_values.uniq.size == 1
  	  cards_string += "s"
  	else
  	  cards_string += "o"
  	end
  end
end

LevelTwo.new
