define_stage :main_menu do

  setup do
    menu = create_actor :menu, x: 300, y: 200

    menu.when :start do |player_count|
      puts "MENU STARTING"
      fire :next_stage, player_count: player_count
    end
  end
end

