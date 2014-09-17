# Class for tracking player stats and score
# accuracy, bombs used, etc
class ScoreKeeper
  construct_with :backstage

  def reset(num_players)
    backstage[:scores] ||= {}
    num_players.times do |i|
      backstage[:scores][i+1] ||= 0
    end
  end

  def player_score(player, score = 1)
    current_score = backstage[:scores][player.number]
    current_score = [current_score+score, 0].max
    backstage[:scores][player.number] = current_score
  end

end
