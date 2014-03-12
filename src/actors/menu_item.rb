define_actor :menu_item do
  
  has_behaviors do
    positioned
    layered ZOrder::HudText
  end

  behavior do
    requires :stage

    setup do
      label_attributes = actor.attributes.dup
      label_attributes.delete :view
      label = stage.create_actor :label, label_attributes
      actor.has_attributes( label: label,
                          selected: false)

      # BUG in label
      label.text = ""
      label.text = actor.text
    

      reacts_with :selected
    end

    remove do
      actor.label.remove
    end

  end

  view do
    draw do |target, x_off, y_off, z|
      if actor.selected?
        x = actor.x
        y = actor.y

        offset_x = x+x_off
        offset_y = y+y_off

        width = actor.label.width
        height = actor.label.height
        padding = 20

        target.draw_box offset_x-padding, offset_y, offset_x+width+padding, offset_y+height, actor.color, z
      end
    end
  end
end
