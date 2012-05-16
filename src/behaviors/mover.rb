define_behavior :mover do
  requires_behaviors :positioned
  requires :director, :viewport
  setup do
    actor.has_attributes speed: opts[:speed] 

    director.when :update do |time|
      velocity = actor.speed * time
      actor.x += velocity if actor.move_right?
      actor.x -= velocity if actor.move_left?

      stage_left = 0
      stage_right = viewport.width-20 

      if actor.x > stage_right
        actor.x = stage_right 
      elsif actor.x < stage_left
        actor.x = stage_left 
      end

    end
  end
end
