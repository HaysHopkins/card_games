class Card
  attr_reader :face, :suit

  class << self
    def face_displays
      Hash[faces.zip %w(2 3 4 5 6 7 8 9 T J Q K A)]
    end

    def face_values
      Hash[faces.zip 2..14]
    end

    def faces
      %i(two three four five six seven eight nine ten jack queen king ace)
    end

    def suit_displays
      Hash[suits.zip %w(♣ ♦ ♥ ♠)]
    end

    def suit_values
      Hash[suits.zip 0..3]
    end

    def suits
      %i(clubs diamonds hearts spades)
    end
  end

  def initialize face, suit
    @face = face
    @suit = suit
  end

  def face_value
    self.class.face_values[face]
  end

  def suit_value
    self.class.suit_values[suit]
  end

  def to_s
    "#{face_display}#{suit_display}"
  end

  def face_display
    self.class.face_displays[face]
  end

  def suit_display
    self.class.suit_displays[suit]
  end
end
