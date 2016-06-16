class ProgressBar
  attr_accessor :chip_goal

  def initialize level_goal
  	@chip_goal = level_goal
  end

  def get_progress user_chips
  	user_chips / @chip_goal.to_f
  end

  def display_progress_bar progress
    puts "Progress Bar:"
    2.times do |i|
      bar = "|"
      ((progress * 50).round).times do ||
      	bar += "*"
      end
      (50 - (progress * 50).round).times do ||
      	bar += " "
      end
      bar += "|"
      puts bar	
    end
    key = "0"
    (55 - (1 + @chip_goal.to_s.length)).times do ||
      key += " "	
    end
    key += @chip_goal.to_s
    puts key	
  end
end