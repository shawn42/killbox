define_behavior :gravity do
  requires :director
  setup do
    actor.has_attributes gravity: opts[:dir]

    director.when :update do |time|
      actor.vel += (actor.gravity * time)
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end
end
