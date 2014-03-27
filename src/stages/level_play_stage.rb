define_stage :level_play do
  render_with :multi_viewport_renderer
  requires :score_keeper, :sound_manager, :config_manager,
    :bomb_coordinator, :bullet_coordinator, 
    :sword_coordinator, :black_hole_coordinator

  curtain_down do |*args|
    sound_manager.stop_music :smb11
    director.unsubscribe_all self
    input_manager.clear_hooks
  end

  curtain_up do |*args|
    opts = args.first || {}
    input_manager.reg :down, KbEscape do
      fire :change_stage, :map_select
    end

    input_manager.reg :down, KbQ do
      if $profiling
        result = RubyProf.stop
        printer = RubyProf::GraphPrinter.new(result)
        printer.print(STDOUT, min_percent: 6)
        # PerfTools::CpuProfiler.stop
      else
        require 'ruby-prof'
        RubyProf.start
        # require 'perftools'
        # PerfTools::CpuProfiler.start("/tmp/killbox_#{Time.now.to_i}_profile")
        $profiling = true
      end
    end

    director.update_slots = [:first, :before, :update, :last]

    @console = create_actor(:console, visible: false)
    setup_level backstage[:level_name]
    setup_players backstage[:player_count]

    sound_manager.play_music :smb11, repeat: true

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
    @console.react_to :watch, :fps do Gosu.fps end
    @console.react_to :watch, :gc_stat do GC.stat.to_s end
    # @console.react_to :watch, :vel do player.vel end
  end

  helpers do
    attr_accessor :players, :viewports

    def setup_level(name)
      @level = LevelLoader.load self, name
    end

    def setup_players(player_count=1)
      @computer_players = []
      @players = []
      starting_positions = @level.zones.select{ |zone| zone.type=="start_location" }.sample(player_count)
      starting_positions.each.with_index do |start_zone, i|
        number = i + 1
        name = "player#{number}".to_sym

        zone_properties = start_zone.properties
        rotation = (zone_properties['rotation'] || 0).to_i

        zone_rect = Rect.new start_zone.x, start_zone.y, start_zone.width, start_zone.height
        x = zone_rect.centerx
        y = zone_rect.centery

        player = create_actor :player, {
          map: @level.map,
          x: x,
          y: y,
          rotation: 0,
          number: number}.merge(initial_position(rotation))
          # vel: player_velocity(rotation)

        player.rotation = rotation # needed to trigger behaviors
        player.animation_file = "trippers/#{player_color(i)}_tripper.png"
        player.controller.map_controls(controls[name])

        @players << player
      end
      renderer.viewports = PlayerViewport.create_n @players, config_manager[:screen_resolution]
    end

    def player_color(index)
      %w(red green purple blue)[index]
    end

    def initial_position(rotation)
      {
        0 => {vel: vec2(0,-0.30), ground_normal: Look::DIRECTIONS[:up]},
        180 => {vel: vec2(0,0.30), ground_normal: Look::DIRECTIONS[:down]},
        90 =>  {vel: vec2(-0.3,0), ground_normal: Look::DIRECTIONS[:right]},
        270 => {vel: vec2(0.3,0), ground_normal: Look::DIRECTIONS[:left]},
      }[rotation]
    end

    def controls
      config_manager[:controls]
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

