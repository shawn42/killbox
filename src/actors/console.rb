define_actor :console do
  has_behaviors do
    layered ZOrder::Console
  end

  behavior do
    requires :stage, :input_manager, :font_style_factory, :director
    setup do |opts|
      actor.has_attributes shown: false,
                           watch_labels: []

      input_manager.reg :down, KbF1 do
        toggle_console
      end

      actor.when :remove_me do
        actor.watch_labels.each &:remove
      end

      director.when :update do
        update_watch_labels
      end

      actor.when :show_me do
        actor.watch_labels.each do |wl|
          wl[2].react_to :show
        end
      end
      actor.when :hide_me do
        actor.watch_labels.each do |wl|
          wl[2].react_to :hide
        end
      end

      reacts_with :watch
    end

    helpers do

      def watch(name, &block)
        raise "too many watches" if actor.watch_labels.size > 4
        label = stage.create_actor(:label, actor.attributes.merge(y: actor.watch_labels.size * 40))
        actor.watch_labels << [name, block, label]
      end

      def update_watch_labels
        actor.watch_labels.each do |label_info|
          name, block, label = *label_info
          label.text = "#{name}: #{block.call}"
        end
      end

      def toggle_console
        if actor.visible?
          actor.emit :hide_me
        else
          actor.emit :show_me
        end

        actor.visible = !actor.visible
      end
    end

  end

  view do
    draw do |target, x_off, y_off, z|
      @color ||= Color.new(150, 10, 10, 10)
      target.fill 0, 0, target.width, 200, @color, ZOrder::Console if actor.visible?
    end

  end
end
