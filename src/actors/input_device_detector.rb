define_actor :input_device_selector do

  has_behaviors do
    positioned
    layered ZOrder::Menu
  end

  behavior do
    setup do
      actor.has_attribute :current_input_device_label
    end

    remove do
    end
  end

  view do
    draw do |target, x_off, y_off, z|
      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off

      target.fill offset_x, offset_y, offset_x+100, offset_y+40, Colors.gray.fade, ZOrder::HudText
    end
  end
end
