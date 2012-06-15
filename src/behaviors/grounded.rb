# needed to prevent us from mid-air jumping if you've run off a
# cliff
define_behavior :grounded do
  requires :director
  setup do
    actor.has_attributes on_ground: false

    actor.when :hit_bottom do
      puts "HIT GROUND"
      actor.on_ground = true
    end

    director.when :update do |time|
      puts "NOT ON GROUND"
      # actor.on_ground = false
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end
end
