define_actor :console do
  has_behaviors do
    positioned
    layered ZOrder::Console
  end

  behavior do
    requires :stage, :input_manager, :font_style_factory
    setup do |opts|

      actor.has_attributes font_size: 25,
                           font_name: "typewriter-mono.ttf",
                           color:     [250,250,250,255], 
                           watch_labels: {},
                           visible: false

      font_style = font_style_factory.build actor.font_name, actor.font_size, actor.color
      actor.has_attributes font_style: font_style

      input_manager.reg :down, KbF1 do toggle_console end

      $debug_drawer.draw "console" do |target|
        if actor.visible?
          @color ||= Color.new(150, 10, 10, 10)
          height = max(font_style.size * actor.watch_labels.size, 30)
          target.fill 1, 0, target.width, height, @color, ZOrder::Console
          target.draw_box 1, 0, target.width, height, Color::WHITE, ZOrder::Console

          actor.watch_labels.keys.each.with_index do |key, i|
            callback = actor.watch_labels[key]
            target.print "#{key}: #{callback.call}", actor.x + 4, actor.y + i * font_style.size, ZOrder::Console, actor.font_style
          end
        end
      end

      reacts_with :watch, :unwatch
    end

    helpers do
      include MinMaxHelpers

      def unwatch(name)
        actor.watch_labels.delete(name)
      end

      def watch(name, &block)
        # raise "too many watches" if actor.watch_labels.size > 4
        actor.watch_labels[name] = block
      end

      def toggle_console
        actor.visible = !actor.visible
      end
    end

  end
end
