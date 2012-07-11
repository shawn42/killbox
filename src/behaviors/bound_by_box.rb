define_behavior :bound_by_box do
  setup do
    actor.has_attributes x: 0,
                         y: 0,
                         width: 0, 
                         height: 0,
                         rot: 0

    actor.has_attributes bb: Rect.new(actor.x, actor.y, 
                                      actor.width, actor.height)


    actor.when :rot_changed do
      # TODO for better collision detection later, update bb here
    end

    actor.when :x_changed do
      actor.bb.x = actor.x - actor.width/2
    end
    actor.when :y_changed do
      actor.bb.y = actor.y - actor.height/2
    end
    actor.when :width_changed do
      actor.bb.width = actor.width
    end
    actor.when :height_changed do
      actor.bb.height = actor.height
    end
  end

end
