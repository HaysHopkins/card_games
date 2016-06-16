require_relative './pot'
require_relative './deck'
require_relative './player'
require_relative './poker_calculator'
require_relative './level_one'
require_relative './level_two'
require_relative './level_three'
require_relative './progress_bar'

class TexasHoldemDealer
  def initialize players
    @deck = Deck.new
    @players = players
    @betting_rotation = players.dup
    @currently_in_game = players.dup
    @table = Player.new('Table', false)
    @pot = Pot.new
    @currently_folded = []
    @level_arr = [LevelOne.new, LevelTwo.new]
    @level = @level_arr.shift
    @progress_bar = ProgressBar.new(@level.level_goal)
    display_level_info
    puts "", "Calibrating Super Texas Holdem Game . . ."
    @level_arr << LevelThree.new
  end

  def play_game
    hole_cards 1
    the_flop 2
    the_turn 3
    the_river 4
    end_round
    continue_playing?
  end

  private

  def hole_cards round
    @deck.deal 2, *@currently_in_game
    display_cards
    bet(round)
  end

  def the_flop round
    @deck.deal 3, @table
    display_cards
    bet(round)
  end

  def the_turn round
    @deck.deal 1, @table
    display_cards
    bet(round)
  end

  def the_river round
    @deck.deal 1, @table
    display_cards
    bet(round)
  end

  def end_round
    counter = 0
    puts "", "", " Final Hands:" unless @currently_in_game.length < 2
    display_cards(true) unless @currently_in_game.length < 2

    while (@pot.pot > 0 && counter < 3)
      counter += 1
      winner = @table
      winning_hand = @table.hand

      @currently_in_game.each do |player|
        combinations = player.combined_hand_with(@table)
        combinations.each do |player_hand|
          if player_hand > winning_hand
            winner = player
            winning_hand = player_hand
          end
        end
      end

      if winner == @table && @currently_in_game.length > 1
        return_bets
        puts "", "******* The pot is split. *******", ""
        break
      elsif winner == @table && @currently_in_game.length == 1
        winner = @currently_in_game.first
      end

      winnings = distribute_pot(winner)
      break if winnings == 0
      if counter == 1
        puts "", "******* #{winner.name} wins #{winnings} with #{winning_hand.name}. *******", ""
      else
        puts "", "******* #{winner.name} wins sidepot (#{winnings}) with #{winning_hand.name}. *******", ""
      end
    end
  end

  def continue_playing?
    input = ''
    while(input != 'yes' && input != 'no')
      puts "Would you like to continue playing: 'Yes' or 'No'?"
      input = $stdin.gets.strip.downcase
    end
    if input == 'yes'
      reset_round
      play_game
    else
      puts 'Goodbye'
    end
  end

  def distribute_pot winner
    winnings = winner.total_bet
    @betting_rotation.each do |player|
      if player != winner
        if player.total_bet >= winner.total_bet
          winnings += winner.total_bet
          player.total_bet -= winner.total_bet
        else
          winnings += player.total_bet
          player.total_bet = 0
        end
      end
    end
    winner.total_bet = 0
    if @pot.pot > winnings
      winner.chips += winnings
      @pot.pot -= winnings
      @currently_in_game.delete(winner)
    else
      winner.chips += winnings
      @pot.pot = 0
    end
    winnings
  end

  def return_bets
    @betting_rotation.each do |player|
      player.chips += player.total_bet
      player.total_bet = 0
    end
  end

  def display_cards display=false
    puts ""
    @currently_in_game.each do |player|
      if !player.is_computer? || display
        puts player
      else
        puts player.name + ': ["*", "*"]'
      end
    end
    puts @table
    puts '------------'
    puts '------------'
  end

  def display_progress
    "---------------------------------------------"
    user_chips = display_chip_count
    progress = @progress_bar.get_progress(user_chips)
    if no_player
      end_game
    elsif progress >= 1 || @betting_rotation.length == 1
      next_level
    else
      @progress_bar.display_progress_bar(progress)
    end 
    "---------------------------------------------"
  end

  def no_player
    player = @betting_rotation.each do |player|
      if !player.is_computer?
        player = true
        break
      end
    end
  end

  def display_chip_count
    user_chips = 0
    puts "", "Current Chip Count:"
    @players.each do |player|
      if player.chips >= @pot.big_blind
        puts "#{player.name}: #{player.chips} chips"
      else
        puts "#{player.name}: Defeated!"
      end
      user_chips = player.chips unless player.is_computer?
    end
    puts ""
    user_chips
  end

  def next_level
    if @level_arr.length == 0
      end_game
    end
    @level = @level_arr.shift
    @progress_bar.chip_goal = @level.level_goal
    @pot.big_blind = @level.big_blind
    @pot.small_blind = @level.small_blind
    @pot.min_bet = @level.big_blind
    @players.each do |player|
      player.chips = @level.level_start
    end
    @betting_rotation = @players.dup
    @currently_in_game = @players.dup

    display_level_info
  end

  def display_level_info
    puts "", ""
    puts " *******************************", " *******************************", ""
    puts " You are on #{@level.class}!"
    puts ""
    puts " The chip goal is #{@level.level_goal}."
    puts " The big blind is #{@pot.big_blind} and the small blind is #{@pot.small_blind}"
    puts ""
    puts " Good Luck!"
    puts  "", " *******************************", " *******************************"
  end

  def reset_round
    @currently_in_game.clear
    delete = []
    @betting_rotation.each do |player|
      player.clear_hand
      if player.chips < @pot.big_blind
        delete << player
      end
    end
    delete.each do |player|
      @betting_rotation.delete(player)
    end
    player = @betting_rotation.pop
    @betting_rotation.unshift(player)
    @currently_in_game = @betting_rotation.dup
    @table.clear_hand
    @currently_folded = []
    @deck = Deck.new

    display_progress
  end

  def end_game
    puts "", "I CAN'T BELIEVE YOU'VE DONE THIS!", "-----------------------------"
    exit
  end

  

    ### --- THE BETTING LOGIC --- ###
    ### Would refactor this a lot ###
    ###     if I had more time.    ###
    ###            -haiku by Hays ###     

  def bet round
    manage_betting_order(round)
  end

  #The big blind should have an opportunity to raise
  def manage_betting_order round
    bets, checks_or_calls = 0, 0
    
    betting_order = []
    @currently_in_game.each do |player|
      betting_order << player unless player.chips <= 0
    end

    @level.set_odds_array(@currently_in_game, @table, @currently_folded) unless @level.class != LevelThree || round == 1

    while betting_order.size > 1 && bets + checks_or_calls < betting_order.size
      player = betting_order.shift
      
      if player.chips > 0
        
        player_bet = round == 1 && @pot.current_bet < @pot.big_blind ? @pot.small_blind : get_bet_value(player, round)

        if player_bet.is_a?(Fixnum)
          bets, checks_or_calls = 1, 0
          total_due = (@pot.current_bet - player.current_bet) + player_bet
          @pot.pot += player.get_bet_from_player(total_due)
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
          total_due = player.get_bet_from_player(@pot.current_bet - player.current_bet)
          @pot.add_to_pot(total_due)
        end

        betting_order.push(player)
      end
    end

    reset_bets
  end

  def get_bet_value player, round
    response = ""

    while true
      
      if player.is_computer?
        response = get_computer_bet(player, round)
      else
        response = get_player_bet(player)
      end

      if response == "fold"
        return "fold" unless @pot.current_bet == 0
        return "check"
        break
      elsif response == "check"
        if @pot.current_bet > player.current_bet
          puts "Incorrect input" unless player.is_computer?
          next
        else
          break
        end
      elsif response == "call"
        if @pot.current_bet == 0
          puts "Incorrect input" unless player.is_computer?
          next
        else
          break
        end
      end

      bet = response.match(/[0-9]*/).to_s.to_i
      if bet < @pot.min_bet
        puts "The minimum bet is #{@pot.min_bet}." unless player.is_computer?
        next
      elsif bet > 0
        if bet > player.chips
          puts "You do not have enough chips! Enter a lower number!" unless player.is_computer?
          next
        elsif ((@pot.current_bet - player.current_bet) + bet) > player.chips
          puts "You do not have enough chips to raise!" unless player.is_computer?
          next
        else
          return bet
        end
      else
        puts "Incorrect input" unless player.is_computer?
        next
      end
    end

    response
  end

  def get_computer_bet player, round
    if @level.class == LevelOne
      @level.get_bet
    elsif @level.class == LevelTwo
      @level.get_bet(player.hand.cards, @currently_in_game.length)
    else
      @level.get_bet(@currently_in_game.index(player), player.hand.cards, round)
    end
  end

  def get_player_bet player
    if @pot.current_bet >= player.chips
      puts "#{player.name}: Would you like to 'Call' and go all in or 'Fold'?"
      input = $stdin.gets.strip.downcase
    elsif player.chips < @pot.min_bet
      puts "#{player.name}: Your chip level is below the minimum bet of #{@pot.min_bet}.  You can only 'Check' or 'Fold' -- or 'Call' if there is alread a bet."
      input = $stdin.gets.strip.downcase
    elsif player.current_bet > 0
      puts "#{player.name}: Would you like to 'Call' the raise of #{@pot.current_bet - player.current_bet}, re-raise ('#{@pot.min_bet} - #{player.chips - (@pot.current_bet-player.current_bet)}') or 'Fold'?"
      input = $stdin.gets.strip.downcase
    elsif player.current_bet == 0 && @pot.current_bet > 0
      puts "#{player.name}: Would you like to 'Call' the bet of #{@pot.current_bet - player.current_bet}, raise ('#{@pot.min_bet} - #{player.chips - (@pot.current_bet-player.current_bet)}'), or 'Fold'?"
      input = $stdin.gets.strip.downcase
    elsif player.current_bet == 0
      puts "#{player.name}: Would you like to bet ('#{@pot.min_bet} - #{player.chips}'), 'Check', 'Fold'?"
      input = $stdin.gets.strip.downcase
    else
      puts "You should not be here!"
    end
  end

  def reset_bets
    @pot.current_bet = 0
    @betting_rotation.each { |player| player.reset_bet }
  end
end

