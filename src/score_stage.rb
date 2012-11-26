define_stage :score do

  setup do

    x = 400
    y = 300

    4.times do |i|
      score = backstage[:scores][i+1] || 0
      label = create_actor :label, x: x, y: y, text: "P#{i+1}: #{score}", font_size: 70
      y += label.font_size * 2
    end

    input_manager.reg :down do
      fire :change_stage, :level_play
    end
  end

end

