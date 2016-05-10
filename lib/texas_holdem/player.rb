require_relative './hand'

class Player
  attr_accessor :chips, :current_bet, :total_bet
  attr_reader :hand, :name

  def initialize name
    @hand = Hand.new
    @chips = 10000
    @name = name
    @total_bet = 0
    @current_bet = 0
  end

  def combined_hand_with player
    hand.combined_with player.hand
  end

  def get_chips amount
    @chips = chips.to_s.to_i - amount
    @current_bet = current_bet.to_s.to_i + amount
    amount
  end

  def to_s
    "#{name}: #{hand}"
  end

  def reset_bet
    self.total_bet += self.current_bet
    self.current_bet = 0
  end
end
