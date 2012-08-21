define_behavior :bullet do

  requires :director
  requires_behaviors :positioned
  setup do
    actor.has_attributes vel: vec2(0,0)

    # director.when :update do |time, secs|
    #   actor.x += (actor.vel.x * secs)
    #   actor.y += (actor.vel.y * secs)
    # end
  end

end
