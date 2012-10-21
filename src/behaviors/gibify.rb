define_behavior :gibify do
  requires :stage
  setup do
    reacts_with :gibify
  end

  helpers do
    def gibify(args)
      log "GIBIFY"
      force = args[:force] || vec2(0,0)
      count = args[:count] || 30
      count.times do
        vel = vec2(0.5,0).rotate!(degrees_to_radians(rand(359))) * rand(4)
        stage.create_actor :gib, x: actor.x, y: actor.y, vel: vel + force, map: actor.map, size: rand(4)
      end
    end

  end
end
