define_actor :player_control_builder do

  has_behaviors do
    positioned
    layered ZOrder::Menu
  end

  behavior do
    requires :stage
    setup do
      actor.has_attribute :player_input_device_selector, stage.create_actor(:input_device_selector, x: actor.x + 100, y: actor.y + 250)
    end

  end

  view do
    draw do |target, x_off, y_off, z|
      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off

      target.fill offset_x, offset_y, offset_x+300, offset_y+300, Color::WHITE.fade, ZOrder::HudText
    end
  end
end
