define_behavior :bound_by_box do
  setup do
    actor.has_attributes x: 0,
                         y: 0,
                         width: 0, 
                         height: 0,
                         rotation: 0

    # vel_bb is the bb extruded over velocity and rotation and unioned with the current bb
    actor.has_attributes bb: Rect.new, predicted_bb: Rect.new

    # update_attribute(:bb, method(:update_bb)).depends_on(:position, :width, :height, :rotation)
    # update_attribute(:predicted_bb, method(:update_predicted_bb)).depends_on(:bb, :vel, :rot_vel)

    # predicted_bb: [:bb, :vel, :rot_vel]

    actor.when(:position_changed) { update_bb }
    actor.when(:width_changed) { update_bb }
    actor.when(:height_changed) { update_bb }
    actor.when(:rotation_changed) { update_bb }
    actor.when(:vel_changed) { update_bb }
    actor.when(:rot_vel_changed) { update_bb }

    update_bb
  end

  remove do
    actor.unsubscribe_all self
  end

  helpers do
    include MinMaxHelpers

    def update_bb
      collision_points = actor.do_or_do_not(:collision_points)
      vel = actor.do_or_do_not(:vel) || ZERO_VEC_2
      rot_vel = actor.do_or_do_not(:rot_vel) || 0

      if collision_points
        min_x = actor.x
        max_x = actor.x
        min_y = actor.y
        max_y = actor.y
        collision_points.each do |pt|
          min_x = min(min_x, pt.x)
          min_y = min(min_y, pt.y)
          max_x = max(max_x, pt.x)
          max_y = max(max_y, pt.y)
        end

        actor.bb.x = min_x - 1
        actor.bb.y = min_y - 1
        actor.bb.width = max_x - min_x + 1
        actor.bb.height = max_y - min_y + 1


        rotation = degrees_to_radians(actor.rotation + rot_vel)
        moved_rotated_points = actor.collision_point_deltas.map do |delta_point| 
          (delta_point).rotate(rotation) + actor.position + vel
        end

        moved_rotated_points.each do |pt|
          min_x = min(min_x, pt.x)
          min_y = min(min_y, pt.y)
          max_x = max(max_x, pt.x)
          max_y = max(max_y, pt.y)
        end

        actor.predicted_bb.x = min_x - 1
        actor.predicted_bb.y = min_y - 1
        actor.predicted_bb.width = max_x - min_x + 1
        actor.predicted_bb.height = max_y - min_y + 1
      else
        actor.bb.x = actor.x - actor.width/2
        actor.bb.y = actor.y - actor.height/2
        actor.bb.width = actor.width
        actor.bb.height = actor.height

        actor.predicted_bb = actor.bb.union(actor.bb.move(vel.x,vel.y))
      end
    end
  end


end
