

class LevelThree
  attr_accessor :poker_odds

  def initialize
    @pc = PokerCalculator.new
    @poker_odds = []
  end

  def get_bet player
    odds = @poker_odds[player][:win_pct]
    bet = ""
    puts "-------------------"
    puts "The Odds are: "
    puts odds
    odds *= 100
    puts "Odds * 100 are:"
    puts odds
	if odds > 90
	  bet = ["call", "check", "200", "250", "300", "350"].sample
	elsif odds > 75
	  bet = ["call", "check", "100", "150"].sample
	elsif odds > 60
	  bet = ["call", "check", "50", "75"].sample
	elsif odds > 45
	  bet = ["call", "check"].sample
	else
	  bet = ["fold", "check"].sample
    end
    puts "The Bet is: "
    puts bet
    puts "-------------------"
    bet
  end

  def set_odds_array currently_in_game, table, folded
    hands = []
    community_cards = []
    folded_players = []

    currently_in_game.each do |player|
      hand = []
      player.hand.cards.each do |card|
        hand << card.to_s
      end
      hands << hand
    end

    table.hand.cards.each do |card|
      community_cards << card.to_s
    end

    if folded && folded.length > 0
      folded.each do |player|
        hand = []
        player.hand.cards.each do |card|
      	  hand << card.to_s
        end
        folded_players << hand
      end
    end

    @poker_odds = @pc.output(hands, community_cards, folded_players)
  end
end