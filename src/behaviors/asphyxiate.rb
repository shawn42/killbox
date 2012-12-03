define_behavior :asphyxiate do
  requires :map_inspector, :director
  
  setup do
    director.when :update do |time, time_secs|
      pos = vec2 actor.x, actor.y
      if map_inspector.out_of_bounds?(actor.map.map_data, pos)
        actor.when :action_loop_complete do
          actor.animating = false
          actor.remove
        end
          
        unless actor.action == :asphyxiate
          puts actor.action
          actor.action = :asphyxiate 
        end
      end
    end
    
    reacts_with :remove
  end
  
  helpers do
    def remove
      director.unsubscribe_all self
      actor.unsubscribe_all self
    end
  end
end

