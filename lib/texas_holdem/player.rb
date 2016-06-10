require_relative './hand'

class Player
  attr_accessor :chips, :current_bet, :total_bet, :hand
  attr_reader :name

  def initialize name
    @hand = Hand.new
    @chips = 10000
    @name = name
    @total_bet = 0
    @current_bet = 0
    @computer = false 
  end


  def combined_hand_with player
    hand.combined_with player.hand
  end

  def is_computer?
    @computer
  end

  def get_bet
    if is_computer?

      return 
    end

    if player.current_bet > 0
      puts "#{player.name}: Would you like to 'Call' the raise of #{@pot.current_bet - player.current_bet}, re-raise ('#{@pot.min_bet} - #{@pot.max_bet}') or 'Fold'?"
      input = $stdin.gets.strip.downcase
    elsif player.current_bet == 0 && @pot.current_bet > 0
      puts "#{player.name}: Would you like to 'Call' the bet of #{@pot.current_bet - player.current_bet}, raise ('#{@pot.min_bet} - #{@pot.max_bet}'), or 'Fold'?"
      input = $stdin.gets.strip.downcase
    elsif player.current_bet == 0
      puts "#{player.name}: Would you like to bet ('#{@pot.min_bet} - #{@pot.max_bet}'), 'Check', 'Fold'?"
      input = $stdin.gets.strip.downcase
    else
      puts "You should not be here!"
    end
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

  def clear_hand
    @hand = Hand.new
  end
end
