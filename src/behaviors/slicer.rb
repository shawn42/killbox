define_behavior :slicer do
  requires :timer_manager, :stage, :sword_coordinator
  setup do
    actor.has_attributes can_slice: true,
                         lunge_distance: 15,
                         slice_recharge_time: 600, 
                         slice_reach: 50
                        
    set_reach
    sword_coordinator.register_sword actor
    actor.when(:failed_to_shoot) { slice_if_able }
    actor.when(:on_ground_changed) { set_reach }
    reacts_with :remove
    actor.can_slice = true
  end

  helpers do
    def set_reach
      actor.slice_reach = actor.on_ground? ? 120 : 50
    end

    def setup_can_slice_timer
      timer_manager.add_timer timer_name, actor.slice_recharge_time, false do
        actor.can_slice = true
      end
    end

    def slice_if_able
      if actor.can_slice?
        actor.can_slice = false
        actor.react_to :play_sound, :slice

        if actor.on_ground?
          points = actor.collision_points
          sign = actor.do_or_do_not(:flip_h) ? 1 : -1
          actor.vel += (points[5] - points[4]).unit * actor.lunge_distance * sign
        end

        actor.when(:action_loop_complete) { actor.action = :idle }
        actor.action = :slice
        actor.emit :slice

        setup_can_slice_timer
      end
    end

    def timer_name
      "#{actor.object_id}:slice_recharge"
    end

    def remove
      actor.can_slice = false
      timer_manager.remove_timer timer_name
      actor.unsubscribe_all(self)
    end
  end

end

