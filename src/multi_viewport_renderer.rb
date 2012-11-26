class MultiViewportRenderer < Renderer
  construct_with :viewport, :director
  attr_accessor :viewports

  def initialize
    $debug_drawer = DebugDraw.new
    director.when :update do |time|
      @viewports.each { |vp| vp.update time }
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

  private
  def draw_viewport(target, viewport)
    screen_bounds = viewport.screen_bounds
    center_x = screen_bounds.width / 2 + screen_bounds.x
    center_y = screen_bounds.height / 2 + screen_bounds.y

    target.draw_box(
      screen_bounds.x,
      screen_bounds.y, 
      screen_bounds.x+screen_bounds.width,
      screen_bounds.y+screen_bounds.height, Color::BLACK, ZOrder::HudText)

    target.clip_to(*screen_bounds) do
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
