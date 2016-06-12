class LevelOne

	def initialize
		@bets = [["fold"], ["check"], ["call"], ["fold"], ["check"], ["call"], ["50"], ["100"], ["50", "100", "50", "100", "150", "200", "250", "300", "350", "400", "450", "500"]]
	end

	def get_bet cards
		decision = @bets.sample()
		decision.sample()
	end
end
