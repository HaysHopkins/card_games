#May need to make this more abstract as I add more games that use it
#RIGHT NOW, NOT HAVING ENOUGH MONEY RESULTS IN YOU FOLDING FOR THE HAND; WILL NEED TO INTRODUCE SIDE POTS
class BetManager
  def initialize
    @pot = 0
    @min_bet = 50
    @max_bet = 500
    @total_bet = 0
  end

  def bet(players)
    manage_betting_order(players)
  end

  #the player is only getting what the other person bet, not its money back
  #if a player bets at end and another player folds, the original player does not
  #get its money back
  def award_pot(player)
    pot_value = pot
    player.chips += pot
    @pot = 0
    pot_value
  end

  private

  attr_reader :max_bet, :min_bet, :pot, :total_bet

  def manage_betting_order(players)
    bets, checks_or_calls = 0, 0
    still_in_game = players
    while players.size > 1 && bets + checks_or_calls < players.size
      player = still_in_game.shift
      player_bet = get_bet_value(player)
      if player_bet.is_a?(Fixnum)
        bets, checks_or_calls = 1, 0
        @total_bet = total_bet.to_s.to_i + player.get_chips(player_bet)
      elsif player_bet == "fold"
        next
      elsif player_bet == "check"
        checks_or_calls += 1
      else
        checks_or_calls += 1
        bet = player.get_chips(total_bet-player.current_bet)
        add_to_pot(bet)
      end
      still_in_game.push(player)
    end
    reset_bets(players)
    still_in_game
  end

  def get_bet_value(player)
    bet = 0
    while true
      response = get_bet(player)
      if response == "fold"
        break
      elsif response == "check"
        if total_bet > player.current_bet
          puts "Incorrect input"
          next
        else
          break
        end
      elsif response == "call"
        if total_bet == 0
          puts "Incorrect input"
          next
        else
          break
        end
      end
      bet = response.match(/[0-9]*/).to_s.to_i
      if bet < min_bet || bet > max_bet
        next
      elsif bet > 0
        #Will need to alter this later for side pots
        #Should I wait to add to the pot?
        if bet > player.chips #THIS IS WHERE SIDEBETS WOULD COME INTO PLAY\
          return "fold"
        else
          return bet
        end
      else
        puts "Incorrect input"
        next
      end
    end
    response
  end

  def get_bet(player)
    if player.current_bet > 0
      #When asking to raise, it will say by full amount instead of difference
      puts "#{player.name}: Would you like to 'Call' the raise of #{total_bet - player.current_bet}, re-raise ('#{min_bet} - #{max_bet}') or 'Fold'?"
      input = $stdin.gets.strip.downcase
    elsif player.current_bet == 0 && total_bet > 0
      puts "#{player.name}: Would you like to 'Call' the bet of #{total_bet - player.current_bet}, re-raise ('#{min_bet} - #{max_bet}'), or 'Fold'?"
      input = $stdin.gets.strip.downcase
    elsif player.current_bet == 0
      puts "#{player.name}: Would you like to bet ('#{min_bet} - #{max_bet}'), 'Check', 'Fold'?"
      input = $stdin.gets.strip.downcase
    else
      puts "You should not be here!"
    end
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
