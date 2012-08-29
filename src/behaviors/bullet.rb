define_behavior :bullet do

  requires :director, :stage
  requires_behaviors :positioned
  setup do
    actor.has_attributes vel: vec2(0,0)

    # always emits the event, but will have nil collisions if we didn't collide
    # with anything
    actor.when :tile_collisions do |collisions|
      if collisions
        # not sure if this should just be a different animation set for bullet?
        # actor.action = :exploding
        # actor.when :animation_finishes { actor.remove }

        # vs
        #
        # stage.create_actor :explosion, x: actor.x, y: actor.y
        actor.remove
      else
        # player collisions?
        (stage.players - [actor.player]).each do |target|
          if target.bb.collide_point?(actor.x, actor.y)
            if target.alive?
              target.react_to :play_sound, :death
              target.remove
              actor.remove
              # TODO GIBS!!
            end
          end
        end

      end
    end

    # director.when :update do |time, secs|
    #   actor.x += (actor.vel.x * secs)
    #   actor.y += (actor.vel.y * secs)
    # end
  end

end
