require_relative './hand'

class Player
  attr_accessor :chips, :current_bet, :total_bet, :hand
  attr_reader :name

  def initialize name, computer
    @hand = Hand.new
    @chips = 10000
    @name = name
    @total_bet = 0
    @current_bet = 0
    @computer = computer
  end


  def combined_hand_with player
    hand.combined_with player.hand
  end

  def is_computer?
    @computer
  end

  def get_bet_from_player bet
    if bet > @chips
      bet = @chips.to_s.to_i
      @current_bet = current_bet.to_s.to_i + bet
      @chips = 0
    else
      @chips = chips.to_s.to_i - bet
      @current_bet = current_bet.to_s.to_i + bet
    end
    bet
  end

  def get_winnings_from_player
    total_bet = @total_bet
    @total_bet = 0
    total_bet
  end

  def to_s
    "#{name}: #{hand}"
  end

  def reset_bet
    self.total_bet += self.current_bet
    self.current_bet = 0
  end

  def clear_hand
    @hand = Hand.new
  end
end
