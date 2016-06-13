require_relative './pot'
require_relative './deck'
require_relative './player'

class TexasHoldemDealer
  def initialize players, level
    @players = players.dup
    @currently_in_game = players.dup
    @currently_folded = []
    @deck = Deck.new
    @table = Player.new 'Table', false
    @pot = Pot.new
    @level = level
  end

  def play_game
    hole_cards
    the_flop
    the_turn
    the_river
    puts '*******'
    determine_winner
    puts '*******'
    continue_playing?
  end

  #private

  def hole_cards
    @deck.deal 2, *@currently_in_game
    display_cards
    bet
  end

  def the_flop
    @deck.deal 3, @table
    display_cards
    bet
  end

  def the_turn
    @deck.deal 1, @table
    display_cards
    bet
  end

  def the_river
    @deck.deal 1, @table
    display_cards
    bet
  end

  def determine_winner
    winning_player = @table
    winning_hand = @table.hand
    @currently_in_game.each do |player|
      combinations = player.combined_hand_with(@table)
      combinations.each do |player_hand|
        if player_hand > winning_hand
          winning_player = player
          winning_hand = player_hand
        end
      end
    end
    award = @pot.award_pot winning_player
    hand_name = winning_hand.name
    puts "#{winning_player.name} wins #{award} with #{hand_name}."
    puts "Current Chip Count:"
    @players.each do |player|
      puts "#{player.name}: #{player.chips} chips"
    end
  end


  # Implement the small and big blind (think about starting chip amount and bet sizes to make sure game can continue for a decent time period)
  def continue_playing?
    input = ''

    while(input != 'yes' && input != 'no')
      puts "Would you like to continue playing: 'Yes' or 'No'?"
      input = $stdin.gets.strip.downcase
    end

    if input == 'yes'
      @currently_in_game = @players.dup
      @folded = 0
      @currently_in_game.each do |player|
        player.clear_hand
      end
      @table = Player.new 'Table', false
      play_game
    else
      puts 'Goodbye'
    end
  end

  def display_cards
    @currently_in_game.each { |player| puts player }
    puts @table
    puts '------------'
    puts '------------'
  end



    ### --- Betting --- ###

  def bet
    manage_betting_order
  end

  def manage_betting_order
    bets, checks_or_calls = 0, 0
    betting_order = @currently_in_game.dup
    @level.set_odds_array(@currently_in_game, @table, @folded) unless @level.class != LevelThree
    # puts "*****************"
    # puts "The Odds At This Time Are: "
    # puts @level.poker_odds
    # puts "*****************"

    while betting_order.size > 1 && bets + checks_or_calls < betting_order.size
      player = betting_order.shift # THIS IS WHERE THE ORDER IS BEING CHANGED, MAYBE USE A TEMPORARY COPY OF C_I_G INSTEAD?
      player_bet = get_bet_value(player)
      
      if player_bet.is_a?(Fixnum)
        bets, checks_or_calls = 1, 0
        total_due = (@pot.current_bet - player.current_bet) + player_bet
        @pot.pot += player.get_chips(total_due)
        @pot.current_bet += player_bet
        player.current_bet = @pot.current_bet
      elsif player_bet == "fold"
        folded_player = @currently_in_game.delete(player)
        @currently_folded << folded_player
        next
      elsif player_bet == "check"
        checks_or_calls += 1
      else
        checks_or_calls += 1
        total_due = player.get_chips(@pot.current_bet - player.current_bet)
        @pot.add_to_pot(total_due)
        player.current_bet = @pot.current_bet
      end
      betting_order.push(player)
    end

    reset_bets
  end

  def get_bet_value player
    response = ""

    while true
      
      if player.is_computer?
        response = get_computer_bet(player)
      else
        response = get_player_bet(player)
      end

      if response == "fold"
        break
      elsif response == "check"
        if @pot.current_bet > player.current_bet
          puts "Incorrect input"
          next
        else
          break
        end
      elsif response == "call"
        if @pot.current_bet == 0
          puts "Incorrect input"
          next
        else
          break
        end
      end

      bet = response.match(/[0-9]*/).to_s.to_i
      if bet < @pot.min_bet || bet > @pot.max_bet
        next
      elsif bet > 0
        # Will need to alter this later for side pots
        if bet > player.chips
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

  def get_computer_bet player
    if @level.class == LevelOne
      @level.get_bet
    elsif @level.class == LevelTwo
      @level.get_bet(player.hand.cards)
    else
      @level.get_bet(@currently_in_game.index(player))
    end
  end

  def get_player_bet player
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

  # IF THE SMALL BLIND FOLDS, I NEED TO FIGURE OUT WHO IS UP IN THE BETTING ORDER WITHOUT
  # CHANGING THE PLAYERS LIST WHICH TRACKS THE BETTING ORDER PROGRESSION AT THE BEGINNING OF EACH ROUND
  def reset_bets
    @pot.current_bet = 0
    @players.each { |player| player.reset_bet }
  end
end

# names = %w(Hays Computer\ 1 Computer\ 2 Computer\ 3)
# players = names.map { |name| Player.new name }
# game = TexasHoldemDealer.new players
# game.hole_cards
# game.the_flop
# game.get_odds_array

