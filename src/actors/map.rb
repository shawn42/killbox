define_actor :map do
  has_attributes tile_size: 50

  has_behaviors do
    positioned
    layered ZOrder::MapBehind
  end
  
  view do
    requires :wrapped_screen
    configure do
      tileset = actor.tileset
      map_image = wrapped_screen.record do
        actor.map_data.tile_grid.each.with_index do |row, x|
          row.each.with_index do |tile, y|
            wrapped_screen.draw_image tileset[tile.gfx_index], x*tile_size, y*tile_size, z 
          end
        end
      end
      actor.has_attribute :map_image, map_image
    end
    
    draw do |target, x_off, y_off, z|
      target.draw_image actor.map_image, x_off, y_off, z
    end
  end
end


