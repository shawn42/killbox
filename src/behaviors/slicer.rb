define_behavior :slicer do
  requires :timer_manager, :stage, :sword_coordinator
  setup do
    actor.has_attributes can_slice: true,
                         lunge_distance: 20,
                         slice_recharge_time: 600, 
                         slice_reach: 40
                        
    sword_coordinator.register_sword actor
    actor.when(:failed_to_shoot) { slice_if_able }
    reacts_with :remove
    actor.can_slice = true
  end

  helpers do

    def setup_can_slice_timer
      timer_manager.add_timer timer_name, actor.slice_recharge_time do
        actor.can_slice = true
        timer_manager.remove_timer timer_name
      end
    end

    def slice_if_able
      if actor.can_slice?
        log "SLICING"
        actor_loc = vec2(actor.x, actor.y)

        actor.can_slice = false
        actor.react_to :play_sound, :shoot

        looking = actor.flip_h? ? vec2(-1,0) : vec2(1,0)
        rotated_look = looking.rotate!(degrees_to_radians(actor.rotation)) * actor.slice_reach

        if actor.on_ground?
          log "LUNGE"
          # actor.vel += directional_vec * lunge amount
        end

        log "SWING #{rotated_look}"
        # sword_loc = actor_loc + rotated_look
        # stage.create_actor :slice_effect, x: sword_loc.x, y: sword_loc.y, view: :graphical_actor_view

        stage.create_actor :slice_effect, parent: actor, offset_from_parent: rotated_look, 
          view: :graphical_actor_view

        actor.emit :slice

        setup_can_slice_timer
      end
    end

    def timer_name
      "#{actor.object_id}:slice_recharge"
    end

    def remove
      timer_manager.remove_timer timer_name
      actor.can_slice = false
    end
  end

end

