class ComputerInput
  extend Publisher
  can_fire_anything

  def initialize(player)
    @old_input = player.input
  end

  def emit(*args, &blk)
    @old_input.send :fire, *args, &blk
  end

  # TURD
  def unsubscribe_all(*args)
    @old_input.unsubscribe_all *args
  end

  attr_accessor :charging_jump, :walk_left, :walk_right, :charging_bomb, :look_left, :look_up, :look_down, :look_right
  def shoot
    emit :shoot
  end

  def charging_jump?
    @charging_jump
  end
  def charging_bomb?
    @charging_bomb
  end
  def walk_left?
    @walk_left
  end
  def walk_right?
    @walk_right
  end
  def look_up?
    @look_up
  end
  def look_down?
    @look_down
  end
  def look_left?
    @look_left
  end
  def look_right?
    @look_right
  end
end

class ComputerPlayer
  attr_accessor :player
  def initialize(player)
    @player = player
    @input = ComputerInput.new @player
    @player.instance_variable_set('@input_mapper', @input)
    @turn = 0
  end

  def take_turn(time)
    @turn += 1
    if @turn % 480 == 0
      @input.shoot
    end
    if @turn % 80 == 0
      @input.shoot
    end

    if @turn % 500 < 100
      @input.charging_jump = true
    else
      @input.charging_jump = false
    end

    if @turn % 200 > 100
      @input.walk_right = false
      @input.walk_left = true
    else
      @input.walk_right = true
      @input.walk_left = false
    end
  end
end

define_stage :level_play do
  render_with :multi_viewport_renderer
  requires :score_keeper, :bomb_coordinator, :bullet_coordinator, :sword_coordinator

  curtain_up do |*args|
    opts = args.first || {}
    # require 'perftools'
    # PerfTools::CpuProfiler.start("/tmp/foxy_perf.txt")
    # require 'ruby-prof'
    # RubyProf.start
    director.update_slots = [:first, :before, :update, :last]

    @console = create_actor(:console, visible: false)
    @fps = create_actor :fps, x: 100, y: 30

    backstage[:level_name] ||= levels.keys[1]
    backstage[:player_count] ||= opts[:player_count]

    setup_level backstage[:level_name]
    setup_players backstage[:player_count]

    director.when :update do |time|
      unless @restarting
        alive_players = @players.select{|player| player.alive?}
        if @players.size > 1 && alive_players.size < 2
          last_man_standing = alive_players.first

          (@players - alive_players).each do |player_that_died| 
            score_keeper.player_score(player_that_died, -1)
          end
          round_over 
        end
        @computer_players.each do |npc|
          npc.take_turn time
        end
      end
    end

    # F1 console watch values
    player = @players[0]
    if player
      # @console.react_to :watch, :p1vel do player.vel end
      # @console.react_to :watch, :p2y do player.y.two end
      # @console.react_to :watch, :fps do Gosu.fps end
    end
    input_manager.reg :down, Kb4 do
      # PerfTools::CpuProfiler.stop

      # result = RubyProf.stop
      # printer = RubyProf::FlatPrinter.new(result)
      # printer = RubyProf::GraphHtmlPrinter.new(result)
      # File.open "perf.html", 'w+' do |f|
      #   printer.print(f, min_percent: 2)
      # end
    end

  end

  helpers do
    attr_accessor :players, :viewports

    def levels 
      {
      :trippy => 4,
      :section_a => 4,
      :basic_jump => 1,
      # :advanced_jump => 2,
      # :cave => 4,
      # :hot_pocket => 2,
      }
    end

    def setup_level(name)
      @level = LevelLoader.load self, name
    end

    def setup_players(player_count=1)
      @computer_players = []
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
        player.animation_file = "trippers/#{player_color(index)}_tripper.png"

        # if index == 2
        #   @computer_players << ComputerPlayer.new(player)
        # else
          player.input.map_input(controls[name])
        # end

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
          # '+i' => :shoot,
          # '+o' => :charging_jump,
          # '+p' => :charging_bomb, 
          # '+u' => :shields_up, 
          # '+t' => :look_up,
          # '+f' => [:look_left, :walk_left],
          # '+h' => [:look_right, :walk_right],
          # '+g' => :look_down,

          '+gp0_button_0' => :shoot,
          '+gp0_button_1' => :charging_jump,
          '+gp0_button_2' => :charging_bomb,
          '+gp0_button_3' => :shields_up,
          '+gp0_up' => :look_up,
          '+gp0_left' => [:look_left, :walk_left],
          '+gp0_right' => [:look_right, :walk_right],
          '+gp0_down' => :look_down,
        },
        player3: {
          '+gp1_button_0' => :shoot,
          '+gp1_button_1' => :charging_jump,
          '+gp1_button_2' => :charging_bomb,
          '+gp1_button_3' => :shields_up,
          '+gp1_up' => :look_up,
          '+gp1_left' => [:look_left, :walk_left],
          '+gp1_right' => [:look_right, :walk_right],
          '+gp1_down' => :look_down,
        },
        player4: {
          '+gp2_button_0' => :shoot,
          '+gp2_button_1' => :charging_jump,
          '+gp2_button_2' => :charging_bomb,
          '+gp2_button_3' => :shields_up,
          '+gp2_up' => :look_up,
          '+gp2_left' => [:look_left, :walk_left],
          '+gp2_right' => [:look_right, :walk_right],
          '+gp2_down' => :look_down,
        }
      }

      # they[:player3] = they[:player1]
      # they[:player4] = they[:player1]
      they

    end

    def round_over
      @restarting = true
      timer_manager.add_timer 'restart', 2000 do
        timer_manager.remove_timer 'restart'
        fire :change_stage, :score, {}
      end
    end

  end
end

