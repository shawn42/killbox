define_behavior :animated_with_spritemap do
  requires :resource_manager, :director
  setup do
    @frame_update_time ||= 60
    @frame_time = 0

    @frame_num = 0

    actor.has_attributes action: :idle, 
                         animating: true, 
                         x_scale: @opts[:x_scale] || 1,
                         y_scale: @opts[:y_scale] || 1

    actor.has_attributes :image, :width, :height

    file, rows, cols, actions = opts[:file], opts[:rows], opts[:cols], opts[:actions]
    @spritemap = resource_manager.load_image file
    
    # negatives means rows/cols instead of w/h 
    #   http://www.libgosu.org/rdoc/Gosu/Image.html#load_tiles-class_method
    @sprites = resource_manager.load_tiles file, -cols, -rows
    
    @frames = {}
    actions.each do |action, frames|
      @frames[action] = [@sprites[frames]].flatten
    end

    actor.when :action_changed do |old_action, new_action|
        # puts new_action
      action_changed old_action, new_action
      actor.animating = @frames[new_action].size > 1
    end
    
    action_changed nil, actor.action

    director.when :update do |time|
      if actor.animating
        @frame_time += time
        if @frame_time > @frame_update_time
          next_frame
          @frame_time = @frame_time-@frame_update_time
        end
        set_frame
      end
    end

  end
  
  helpers do
    def next_frame
      action_set = @frames[actor.action]
      @frame_num = (@frame_num + 1) % action_set.size unless action_set.nil?
      # puts @frame_num
    end

    def action_changed(old_action, new_action)
      @frame_num = 0
      set_frame
    end

    def set_frame
      action_set = @frames[actor.action]
      raise "unknown action set #{actor.action} for #{actor}" if action_set.nil?

      image = action_set[@frame_num]
      actor.image = image
      actor.width = image.width
      actor.height = image.height
    end
  end
  
end

