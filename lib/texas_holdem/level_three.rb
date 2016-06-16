require_relative 'level_two'

class LevelThree
  attr_reader :level_goal, :level_start, :big_blind, :small_blind
  attr_accessor :poker_odds

  def initialize
  	@level_goal = 640000
  	@level_start = 160000
  	@big_blind = 8000
  	@small_blind = 4000
    @pc = PokerCalculator.new
    @poker_odds = []
    @hole_bet = LevelTwo.new
  end

  def get_bet player, cards, round
  	odds = if round == 1
  	  (@hole_bet.get_odds(cards, 3)) * 1.5
  	else
      @poker_odds[player][:win_pct] * 100
    end

    odds -= [0, 5, 10, 20, 40].sample if round == 4 && odds == 100

	bet = if odds > 90
	  bet = ["call", "check", "10000", "10000", "16000", "20000", "20000", "40000", "60000", "80000", "100000"].sample
	elsif odds > 75
	  bet = ["call", "check", "call", "check", "8000", "8000", "10000", "10000"].sample
	elsif odds > 60
	  bet = ["call", "check", "call", "check", "4000", "8000"].sample
	elsif odds > 45
	  bet = ["call", "check"].sample
	else
	  bet = ["fold", "check"].sample
    end
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

    if folded
      if folded.length > 0
		folded.each do |player|
		  hand = []
		  player.hand.cards.each do |card|
		  	hand << card.to_s
		  end
		  folded_players << hand
		end
      end
    end
    @poker_odds = @pc.output(hands, community_cards, folded_players)
  end
end