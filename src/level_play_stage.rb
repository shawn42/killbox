define_stage :level_play do
  render_with :multi_viewport_renderer

  helpers do
    attr_accessor :players, :viewports

    def curtain_up(opts={})
      # TODO cleaner way to summon these into existance at the stage context
      # required_stage_hands :bomb_coordinator, :bullet_coordinator, etc.. 
      bomb_c = this_object_context[:bomb_coordinator]
      bullet_c = this_object_context[:bullet_coordinator]
      sword_c = this_object_context[:sword_coordinator]

      director.update_slots = [:first, :before, :update, :last]

      @console = create_actor(:console, visible: false)

      backstage[:level_name] ||= levels.keys[0]
      backstage[:player_count] ||= opts[:player_count]

      setup_level backstage[:level_name]
      setup_players backstage[:player_count]


      director.when :update do |time|
        unless @restarting
          alive_players = @players.select{|player| player.alive?}
          if @players.size > 1 && alive_players.size == 1
            backstage[:scores] ||= {}
            backstage[:scores][alive_players.first.number] ||= 0
            backstage[:scores][alive_players.first.number] += 1
            round_over 
          end
        end
      end

      # F1 console watch values
      player = @players[1]
      if player
        @console.react_to :watch, :p2x do player.x.two end
        @console.react_to :watch, :p2y do player.y.two end
        @console.react_to :watch, :fps do Gosu.fps end
      end

    end


    def levels 
      {
      :trippy => 4,
      # :advanced_jump => 2,
      # :cave => 4,
      # :basic_jump => 1,
      # :hot_pocket => 2,
      }
    end

    def setup_level(name)
      @level = LevelLoader.load self, name
    end

    def setup_players(player_count=1)
      @players = []
      player_count.times do |i|
        setup_player i
      end
      (4-player_count).times do |i|
        remove_player "player#{3-i+1}".to_sym
      end
      renderer.viewports = PlayerViewport.create_n @players, config_manager[:screen_resolution]
    end

    def remove_player(name)
      player = @level.named_objects[name]
      player.remove if player
    end

    def setup_player(index)
      number = index + 1
      name = "player#{number}".to_sym
      player = @level.named_objects[name]
      if player
        player.has_attributes number: number
        player.vel = vec2(0,3)
        player.input.map_input(controls[name])
        player.animation_file = "trippers/#{player_color(index)}_tripper.png"
        @players << player
      end
    end

    def player_color(index)
      %w(red green purple blue)[index]
    end

    def controls
      they = { player1: {
          '+b' => :shoot,
          '+n' => :charging_jump,
          '+m' => :charging_bomb,
          '+v' => :shields_up,
          '+w' => :look_up,
          '+a' => [:look_left, :walk_left],
          '+d' => [:look_right, :walk_right],
          '+s' => :look_down,
        },
        player2: {
          '+i' => :shoot,
          '+o' => :charging_jump,
          '+p' => :charging_bomb, 
          '+u' => :shields_up, 
          '+t' => :look_up,
          '+f' => [:look_left, :walk_left],
          '+h' => [:look_right, :walk_right],
          '+g' => :look_down,

          '+gp_button_0' => :shoot,
          '+gp_button_1' => :charging_jump,
          '+gp_button_2' => :charging_bomb,
          '+gp_button_3' => :shields_up,
          '+gp_up' => :look_up,
          '+gp_left' => [:look_left, :walk_left],
          '+gp_right' => [:look_right, :walk_right],
          '+gp_down' => :look_down,
        }
      }

      they[:player3] = they[:player1]
      they[:player4] = they[:player1]
      they

    end

    def round_over
      @restarting = true
      timer_manager.add_timer 'restart', 2000 do
        timer_manager.remove_timer 'restart'
        fire :change_stage, :score
      end
    end

  end
end

