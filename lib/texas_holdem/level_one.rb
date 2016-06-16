class LevelOne
	attr_accessor :level_goal

	def initialize
	  @level_goal = 40000
	  @bets = [["fold", "check", "call"], ["fold"], ["check"], ["call"], ["check"], ["call"], ["500"], 
	    ["750"], ["1000"], ["500", "750", "1000", "500", "750", "1000", "2000", "1000", "2000", "4000", "5000"]]
	end

	def get_bet
	  decision = @bets.sample()
	  decision.sample()
	end
end
