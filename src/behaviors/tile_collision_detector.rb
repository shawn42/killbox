define_behavior :tile_collision_detector do
  requires :director, :map_inspector
  setup do
    raise "vel required" unless actor.has_attribute? :vel

    director.when :update do |time|
      find_collisions time
    end

    actor.when :remove_me do
      director.unsubscribe_all self
    end
  end

  helpers do
    def find_collisions(time)
      collision_data = {collisions: []}

      map = actor.map.map_data
      
      map_inspector.overlap_tiles(map, box_of_interest) do |tile|
        
      end

      # TODO check map / tiles for collisions
      # collision_data[:collisions] << ...
      actor.emit :tile_collisions, collision_data
    end
  end
end
