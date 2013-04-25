# Class for tracking player stats and score
# accuracy, bombs used, etc
class ScoreKeeper

  construct_with :backstage

  def initialize
    backstage[:scores] ||= {}
    4.times do |i|
      backstage[:scores][i+1] ||= 10
    end
  end

  def player_score(player, score = 1)
    backstage[:scores][player.number] += score
  end

end
