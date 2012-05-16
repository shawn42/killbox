define_actor :map do
  has_attributes tile_size: 50

  has_behaviors do
    positioned
    layered ZOrder::MapTiles
  end
  
  view do
    requires :wrapped_screen, :resource_manager
    configure do
      actor.has_attribute :map_image
    end
    
    draw do |target, x_off, y_off, z|
      unless actor.map_image
        puts "HERE"
        map_data = actor.map_data
        tile_size = map_data.tile_size
        # TODO how to get these?
        width = 40 * tile_size
        height = width
        tileset = resource_manager.load_tiles(map_data.tileset_image, tile_size, tile_size)

        actor.map_image = wrapped_screen.record width, height do
          map_data.tile_grid.each.with_index do |row, y|
            row.each.with_index do |tile, x|
              binding.pry unless tileset[tile.gfx_index]
              wrapped_screen.draw_image tileset[tile.gfx_index], x*tile_size, y*tile_size, z 
            end
          end
        end
      end

      target.draw_image actor.map_image, x_off, y_off, z
    end
  end
end


