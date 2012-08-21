define_behavior :bound_by_box do
  setup do
    actor.has_attributes x: 0,
                         y: 0,
                         width: 0, 
                         height: 0,
                         rotation: Math::PI / 2.0

    actor.has_attributes bb: Rect.new(actor.x, actor.y, 
                                      actor.width, actor.height)


    actor.when :x_changed do
      update_bb
    end
    actor.when :y_changed do
      update_bb
    end
    actor.when :width_changed do
      update_bb
    end
    actor.when :height_changed do
      update_bb
    end
  end

  helpers do
    include MinMaxHelpers
      # vec2(actor.x, actor.y) + point.rotate(actor.do_or_do_not(:rotation) || 0)

    def update_bb
      if actor.has_attribute? :collision_points && false
        min_y = actor.y
        min_x = actor.x
        max_y = actor.y
        max_x = actor.x
        actor.collision_points.each do |pt|
          min_y = min(min_y, pt.y)
          min_x = min(min_x, pt.x)
          max_y = max(max_y, pt.y)
          max_x = max(max_x, pt.x)
        end
        actor.bb.x = min_x
        actor.bb.y = min_y
        actor.bb.width = max_x - min_x
        actor.bb.height = max_y - min_y
      else
        actor.bb.x = actor.x - actor.width/2
        actor.bb.y = actor.y - actor.height/2
        actor.bb.width = actor.width
        actor.bb.height = actor.height
      end
    end
  end


end
