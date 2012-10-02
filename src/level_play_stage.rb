class LevelPlayStage < Stage
  include GameSession

  attr_accessor :players, :viewports

  LEVELS = {
    :advanced_jump => 2,
    :cave => 2,
    :basic_jump => 1,
  }
  def setup
    super
    this_object_context[:bomb_coordinator]
    director.update_slots = [:first, :before, :update, :last]
    $debug_drawer = DebugDraw.new
    backstage[:level_name] ||= LEVELS.keys[0]
    backstage[:player_count] ||= LEVELS.values[0]

    LEVELS.size.times do |i|
      input_manager.reg :down, Object.const_get("Kb#{i}") do
        backstage[:level_name] = LEVELS.keys[i]
        backstage[:player_count] = LEVELS.values[i]

        fire :restart_stage

      end
    end

    setup_level backstage[:level_name]
    setup_players backstage[:player_count]
  end

  def setup_level(name)
    # TODO XXX hack until all other stages are in place
    init_session
    @level = LevelLoader.load self, name
  end

  def setup_players(player_count=1)
    @players = []
    player_count.times do |i|
      setup_player "player#{i+1}".to_sym
    end
    @viewports = PlayerViewport.create_n @players, config_manager[:screen_resolution]
  end

  def setup_player(name)
    player = @level.named_objects[name]
    if player
      player.vel = vec2(0,3)
      player.input.map_input(controls[name])
      @players << player
    end
  end

  def controls
    { player1: {
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
  end

  def update(time)
    super
    @viewports.each do |vp|
      vp.update time
    end

    unless @restarting
      alive_players = @players.select{|player| player.alive?}
      if alive_players.size < @players.size
        round_over
      end
    end
  end

  def round_over
    @restarting = true
    timer_manager.add_timer 'restart', 2000 do
      timer_manager.remove_timer 'restart'
      fire :restart_stage 
    end
  end

  def draw(target)
    @viewports.each do |vp|
      draw_viewport target, vp
    end

    @color ||= Color::BLACK #Color.new 255, 41, 145, 179
    target.fill_screen @color, -1
    $debug_drawer.draw_blocks.each do |name, dblock|
      dblock.call target
    end
  end

  def draw_viewport(target, viewport)
    center_x = viewport.width / 2 + viewport.x_scr_offset
    center_y = viewport.height / 2 + viewport.y_scr_offset

    target.draw_box(
      viewport.x_scr_offset,
      viewport.y_scr_offset, 
      viewport.x_scr_offset+viewport.width,
      viewport.y_scr_offset+viewport.height, Color::BLACK, ZOrder::HudText)

    target.clip_to(*viewport.screen_bounds) do
      target.rotate(-viewport.rotation, center_x, center_y) do
        z = 0
        @parallax_layers.each do |parallax_layer|
          drawables_on_parallax_layer = @drawables[parallax_layer]

          if drawables_on_parallax_layer
            @layer_orders[parallax_layer].each do |layer|

              trans_x = viewport.x_offset parallax_layer
              trans_y = viewport.y_offset parallax_layer

              z += 1
              drawables_on_parallax_layer[layer].each do |drawable|
                drawable.draw target, trans_x, trans_y, z
              end
            end
          end
        end
      end # rotate
    end # clip_to
  end
end

class DebugDraw
  attr_reader :draw_blocks
  def initialize
    clear
  end

  def clear
    @draw_blocks = {}
  end

  def draw(name, &block)
    @draw_blocks[name] = block
  end
end
