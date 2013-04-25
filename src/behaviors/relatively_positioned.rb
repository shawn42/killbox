define_behavior :relatively_positioned do
  setup do
    parent = actor.parent
    actor.has_attributes(
      x: 0,
      y: 0,
      rotation: 0,
      x_scale: parent.flip_h? ? -1 : 1
    )

    actor.offset_from_parent.rotate!(-actor.rotation)

    parent.when(:x_changed) { update_location }
    parent.when(:y_changed) { update_location }
    parent.when(:width_changed) { update_location }
    parent.when(:height_changed) { update_location }
    parent.when(:rotation_changed) { update_location }

    update_location

    reacts_with :remove
  end

  helpers do
    def remove
      actor.parent.unsubscribe_all self
    end

    def update_location
      parent = actor.parent
      parent_pos = parent.position
      rotated_pos = parent_pos + actor.offset_from_parent.rotate(degrees_to_radians(parent.rotation))
      actor.update_attributes x: rotated_pos.x, y: rotated_pos.y, rotation: parent.rotation
    end
  end

end
