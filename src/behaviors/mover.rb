define_behavior :mover do
  requires :director
  setup do
    actor.has_attributes speed: opts[:speed],
                         accel: opts[:accel],
                         max_speed: opts[:max_speed],
                         vel: vec2(0,0)

    director.when :update do |time|

      # TODO performance of creating vecs here instead of modifying in place?
      if actor.move_right?
        actor.vel += vec2(actor.accel * time * actor.speed, 0)
      elsif actor.move_left?
        actor.vel -= vec2(actor.accel * time * actor.speed, 0)
      end

      # TODO jump...

      # trucate to speed
      # actor.vel.magnitude = actor.max_speed if actor.vel.magnitude > actor.max_speed
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end

  helpers do
    include MinMaxHelpers
  end
end
