# needed to prevent us from mid-air jumping if you've run off a cliff
define_behavior :grounded do
  setup do
    actor.has_attributes on_ground: false

    actor.when :jump do
      actor.on_ground = false
    end

    actor.when :hit_bottom do
      actor.action = :idle unless actor.action == :idle
      actor.on_ground = true
    end

  end
end
