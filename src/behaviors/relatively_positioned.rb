define_behavior :relatively_positioned do
  setup do
    parent = actor.parent
    actor.has_attributes(
      x: 0,
      y: 0,
      rotation: 0
    )

    parent.when(:x_changed) { update_location }
    parent.when(:y_changed) { update_location }
    parent.when(:width_changed) { update_location }
    parent.when(:height_changed) { update_location }
    parent.when(:rotation_changed) { update_location }

    update_location
  end

  helpers do
    def update_location
      parent = actor.parent
      offset = actor.offset_from_parent

      # TODO fix for rotational position change
      actor.x = parent.x + offset.x
      actor.y = parent.y + offset.y
      actor.rotation = actor.rotation

    end
  end

end
