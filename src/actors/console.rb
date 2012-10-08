define_actor :console do
  has_behaviors do
    positioned
    layered ZOrder::Console
  end

  behavior do
    requires :stage, :input_manager, :font_style_factory
    setup do |opts|

      actor.has_attributes font_size: 30,
                           font_name: "Asimov.ttf",
                           color:     [250,250,250,255], 
                           watch_labels: [],
                           visible: false

      font_style = font_style_factory.build actor.font_name, actor.font_size, actor.color
      actor.has_attributes font_style: font_style

      input_manager.reg :down, KbF1 do toggle_console end

      $debug_drawer.draw "console" do |target|
        if actor.visible?
          @color ||= Color.new(150, 10, 10, 10)
          target.fill 0, 0, target.width, 200, @color, ZOrder::Console
          target.draw_box 0, 0, target.width, 200, Color::WHITE, ZOrder::Console

          actor.watch_labels.each.with_index do |wl, i|
            target.print "#{wl[0]}: #{wl[1].call}", actor.x, actor.y + i * font_style.size, ZOrder::Console, actor.font_style
          end
        end
      end

      reacts_with :watch
    end

    helpers do

      def watch(name, &block)
        raise "too many watches" if actor.watch_labels.size > 4
        actor.watch_labels << [name, block]
      end

      def toggle_console
        actor.visible = !actor.visible
      end
    end

  end
end
