class Pot
  attr_accessor :pot, :current_bet, :small_blind, :big_blind, :min_bet

  def initialize
    @pot = 0
    @min_bet = 500
    @big_blind = 500
    @small_blind =	250
    @current_bet = 0
  end

  def bet(players)
    manage_betting_order(players)
  end
  
  def award_pot(player)
    pot_value = pot
    player.chips += pot
    @pot = 0
    pot_value
  end

  def add_to_pot(bet)
    @pot = pot + bet
  end

  def reset_bets(players)
    players.each do |player|
      player.current_bet = 0
    end
    @total_bet = 0
  end
end