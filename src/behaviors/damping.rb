define_behavior :damping do
  requires :director
  setup do
    actor.has_attributes damping: opts[:amount]
    director.when :update do |time|
       # TODO only if on the ground?
      if actor.vel.magnitude > 0.001
        actor.vel.magnitude *= actor.damping 
      else
        actor.vel = vec2(0,0)
      end
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end
end
