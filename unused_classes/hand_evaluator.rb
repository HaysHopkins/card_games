require_relative './deck.rb'

class HandEvaluator
  def evaluate_hands(hand, table)
    suits = []
    faces = []
    hand_value = -1
    winning_hand = []
    combinations = [[hand[0]], [hand[1]], hand]
    combinations.each do |player_cards|
      value, hand = get_all_card_combinations(player_cards, table)
      hand_value, winning_hand = value, hand if value > hand_value
    end
    [hand_value, winning_hand]
  end

  def get_hand_value(hand)
    faces = hand.map(&:face)
    suits = hand.map(&:suit)
    get_face_values(faces)
    get_suit_values(suits)
    multiples_eval = check_for_multiples(faces)
    flush_eval = check_for_flush(suits.uniq)
    straight_eval = check_for_straight(faces)
    straight_flush = (straight_eval > 0 && flush_eval > 0) ? 168000 + straight_eval : -1
    [multiples_eval, flush_eval, straight_eval, straight_flush, faces[4]].max
  end

  private

  def get_all_card_combinations(player_cards, table)
    if player_cards.size == 1
      combinations_with_one_card(player_cards, table)
    else
      combinations_with_two_cards(player_cards, table)
    end
  end

  def combinations_with_two_cards(player_cards, table)
    x, y, z = 0, 1, 2
    hand_value = 0
    winning_hand = []
    #There are 10 total combinations, make situational in case I need to call in dif circumstance
    10.times do ||
      hand = [player_cards[0], player_cards[1]]
      if z == 4 && y == 3 && x == 2
        hand += [table[x], table[y], table[z]]
        value = get_hand_value(hand)
        hand_value, winning_hand = value, hand if value > hand_value
        break
      elsif z == 4 && y == 3
        hand += [table[x], table[y], table[z]]
        value = get_hand_value(hand)
        hand_value, winning_hand = value, hand if value > hand_value
        x += 1; y = x + 1; z = y + 1;
      elsif z == 4
        hand += [table[x], table[y], table[z]]
        value = get_hand_value(hand)
        hand_value, winning_hand = value, hand if value > hand_value
        y += 1; z = y + 1;
      else
        hand += [table[x], table[y], table[z]]
        value = get_hand_value(hand)
        hand_value, winning_hand = value, hand if value > hand_value
        z += 1;
      end
    end
    [hand_value, winning_hand]
  end

  def combinations_with_one_card(player_cards, table)
    hand_value = 0
    winning_hand = []
    #There are 5 total combinations, make situational in case I need to call in dif circumstance
    (0..4).each do |skip_index|
      hand = [player_cards[0]]
      (0..4).each do |current_index|
        if current_index != skip_index
          hand << table[current_index]
        end
      end
      value = get_hand_value(hand)
      hand_value, winning_hand = value, hand if value > hand_value
    end
    [hand_value, winning_hand]
  end

  def check_for_multiples(faces)
    multiples = faces.select {|face| faces.count(face) > 1}
    multiples.uniq!
    if multiples.size == 1
      case number = faces.count(multiples[0])
      when 2
        score("Pair", multiples[0])
      when 3
        score("Three of a Kind", multiples[0])
      when 4
        score("Four of a Kind", multiples[0])
      else
        "You should never be here!"
      end
    elsif multiples.size == 2
      number = faces.count(multiples[0])
      number2 = faces.count(multiples[1])
      if number == 2 && number2 == 3
        score("Full House", multiples[1], multiples[0])
      elsif number == 3 && number2 == 2
        score("Full House", multiples[0], multiples[1])
      else
        score("Two Pair", multiples[0], multiples[1])
      end
    else
      -1
    end
  end

  def check_for_flush(suits)
    if suits.size == 1
      score("Flush", suits[0])
    else
      -1
    end
  end

  def check_for_straight(faces)
    if faces.sort.each_cons(2).all? { |x,y| y == x + 1 }
      score("Straight", faces[4])
    elsif faces == [2, 3, 4, 5, 14]
      score("Straight", faces[3])
    else
      -1
    end
  end

  def score(hand, *args)
    case hand
    when "Pair"
      (args[0] * 10) #Range: 20-140
    when "Two Pair"
      (args[0] + 13) * 10 + args[1] #Range: 153-274
    when "Three of a Kind"
      (1 + args[0]) * 100 #Range: 300-1500
    when "Straight"
      args[0] * 400 #Range: 2000-5600
    when "Flush"
      5800
    when "Full House"
      full_house = (1 + args[0]) * 2000 + (args[1] * 10) #Range: 6030-30130
    when "Four of a Kind"
      (2 + args[0]) * 10000 #Range: 40000 - 160000
    else
      puts "You should never be here!"
    end
  end

  def get_suit_values(suits)
    suits.map! { |suit| Deck.suit_values[suit] }
  end

  def get_face_values(faces)
    faces.map! { |face| Deck.face_values[face] }
  end
end
