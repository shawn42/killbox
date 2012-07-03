# needed to prevent us from mid-air jumping if you've run off a
# cliff
define_behavior :grounded do
  requires :director
  setup do
    actor.has_attributes on_ground: false

    director.when :before do |time, time_secs|
      actor.on_ground = false
    end

    actor.when :hit_bottom do
      actor.action = :idle unless actor.action == :idle
      actor.on_ground = true
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end
end
