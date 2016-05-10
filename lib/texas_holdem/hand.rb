require_relative './extra_cards.rb'

class Hand
  include Comparable

  attr_reader :cards, :extra_cards

  class << self
    def names
      [['High Card'       , 2..14   ],
       ['a Pair'          , 15..27  ],
       ['Two Pair'        , 28..41  ],
       ['Three of a Kind' , 42..54  ],
       ['a Straight'      , 55..64  ],
       ['a Flush'         , 65..74  ],
       ['a Full House'    , 75..87  ],
       ['Four of a Kind'  , 88..100 ],
       ['a Straight Flush', 101..109],
       ['a Royal Flush'   , 110     ]]
    end
  end

  def initialize *cards
    @cards = cards
    @extra_cards = ExtraCards.new
  end

  def <=> anOther
    return value <=> anOther.value unless value == anOther.value
    self.set_extra_cards
    anOther.set_extra_cards
    extra_cards <=> anOther.extra_cards
  end

  def << card
    cards << card
  end

  def combined_with hand
    combined_cards = cards + hand.cards
    new_hands = []
    combined_cards.combination(5).each do |five_cards|
      new_hand = Hand.new
      five_cards.each {|card| new_hand << card }
      new_hands << new_hand
    end
    new_hands
  end

  def name
    value_pair = self.class.names.find { |_, range| range === value }
    return unless value_pair
    value_pair.first
  end

  def sorted_cards
    cards.sort_by(&:face_value)
  end

  def to_s
    "#{cards.map(&:to_s)}"
  end

  protected

  def value
    return straight_flush if straight_flush
    return quads if quads
    return full_house if full_house
    return flush if flush
    return straight if straight
    return trips if trips
    return two_pair if two_pair
    return pair if pair
    high_card
  end

  def set_extra_cards
    cards = face_values
    to_delete = face_value_counts.select { |_, count| count >= 2 }
    to_delete.keys.each do |face_value|
      cards.delete(face_value)
    end
    extra_cards.cards = cards
  end

  private

  def high_card
    #set_extra_cards(face_values.reject! { |face| face == face_values.max })
    return face_values.max
  end

  def pair
    pair_count = face_value_counts.find { |_,count| count == 2 }
    return pair_count[0] + 13 if pair_count
  end

  def two_pair
    two_pair_count = face_value_counts.select { |_,count| count == 2 }
    if two_pair_count.size > 1
       return two_pair_count.keys.max + 26 + (two_pair_count.keys.min / 28.0)  
    end
  end

  def trips
    trips_count = face_value_counts.select { |_,count| count == 3 }
    return trips_count.keys[0] + 40 if trips_count.size > 0
  end

  def straight
    return face_values.max + 50 if face_values.each_cons(2).all? { |x,y| y == x + 1 }
    return 55 if face_values == [2, 3, 4, 5, 14]
  end

  def flush
    return face_values.max + 60 if suit_values.uniq.size == 1
  end

  def full_house
    multiples = face_value_counts.select { |_, count| count >= 2 }
    if multiples.values.include?(3) && multiples.size > 1
      return multiples.find { |card, count| count == 3 }[0] + 73 + 
        (multiples.find { |card, count| count == 2 }[0] / 75.0)
    end 
  end

  def quads
    quads_count = face_value_counts.select { |_, count| count == 4 }
    return quads_count.keys[0] + 86 if quads_count.size > 0
  end

  def straight_flush
    if straight == 55 && flush
      101
    elsif flush && straight
      face_values.max + 96
    end
  end

  def face_values
    sorted_cards.map(&:face_value)
  end

  def suit_values
    sorted_cards.map(&:suit_value)
  end

  def face_value_counts
    face_values.each_with_object(Hash.new(0)) { |v, c| c[v] += 1 }
  end
end
