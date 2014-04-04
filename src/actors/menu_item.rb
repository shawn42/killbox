define_actor :menu_item do
  
  has_behaviors do
    positioned
    layered ZOrder::HudText
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
