# needed to prevent us from mid-air jumping if you've run off a cliff
define_behavior :grounded do
  requires :director
  setup do
    actor.has_attributes on_ground: false

    director.when :before do |time, time_secs|
      actor.on_ground = false
    end

    actor.when :hit_bottom do
      ground if gravity?(:down)
    end
    actor.when :hit_top do
      ground if gravity?(:up)
    end
    # these are swapped because the Y axis points down
    actor.when :hit_left do
      ground if gravity?(:left)
    end
    actor.when :hit_right do
      ground if gravity?(:right)
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end
  helpers do
    # vec2(0,1).a => 1.5707963267948966
    # vec2(0,-1).a => -1.5707963267948966
    # vec2(1,0).a => 0.0
    # vec2(-1,0).a => 3.141592653589793

    def ground
      actor.action = :idle unless actor.action == :idle
      actor.on_ground = true
    end

    def gravity?(direction)
      gravity = actor.gravity

      case direction
      when :down
        gravity.y > 0 && gravity.y.abs > gravity.x.abs
      when :up
        gravity.y < 0 && gravity.y.abs > gravity.x.abs
      when :left
        gravity.x < 0 && gravity.x.abs > gravity.y.abs
      when :right
        gravity.x > 0 && gravity.x.abs > gravity.y.abs
      end
    end
  end
end
