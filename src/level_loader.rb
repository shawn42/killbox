class LevelLoader
  class Level
    attr_accessor :map, :objects, :foxy_info, :named_objects, :map_extents
  end

  class MapData
    attr_accessor :tile_grid, :tileset_image, :tile_size, :bg_tile_grid, :fg_tile_grid
  end

  def self.load(stage, level_name="advanced_jump")
    map = Tmx.load("#{APP_ROOT}data/maps/#{level_name}.tmx")

    map_data = MapData.new
    map_data.tile_grid, map_data.bg_tile_grid, map_data.fg_tile_grid = 
      generate_map(map)

    # TODO pull these from the file
    # map.tilesets
    #   firstgid = 1
    #   firstgit = 254
    #   for now just take the first?
    map_data.tileset_image = map.tilesets.first.image
    map_data.tile_size = map.tilesets.first.tilewidth # 36
    # if level_name == :trippy
    #   map_data.tileset_image = "map/tileset.png"
    # else
    #   map_data.tileset_image = "map/space_platform.png"
    # end
    
    Level.new.tap do |level|
      level.map = stage.create_actor :map, map_data: map_data
      level.map_extents = [0,0, 
        map_data.tile_grid[0].size * map_data.tile_size, map_data.tile_grid.size * map_data.tile_size]

      load_objects stage, map, level
    end
  end

  def self.generate_map(map)
    %w(terrain bg fg).map { |name| build_tile_grid(map.layers, name) }
  end

  def self.build_tile_grid(layers, layer_name)
    layer = layers.detect{ |layer| layer.name == layer_name }
    if layer
      Array.new(layer.height).tap do |tile_grid|
        if layer
          layer.height.times do |i|
            tile_grid[i] = Array.new(layer.width)
          end

          data_size = layer.data.size
          # binding.pry
          layer.data.each.with_index do |tile_id, i|
            x = i % layer.width
            y = i / layer.width

            tile = new_tile_for_index(tile_id, x,y)
            binding.pry unless tile_grid[y]
            tile_grid[y][x] = tile
          end
        end
      end
    end
  end

  def self.load_objects(stage, map, level)
    level.objects = []
    level.named_objects = {}

    actors_group = map.object_groups.detect{ |group| group.name == "actors" }
    if actors_group
      actors_group.objects.each do |obj|
        if obj.type
          actor = stage.create_actor(obj.type.to_sym, obj.contents.symbolize_keys.slice(:x,:y,:name,:type).merge(
            map: level.map
          ))
          
          name = obj.name
          level.named_objects[name.to_sym] = actor if name
          level.objects << actor
        end
      end
    end
  end

  def self.new_tile_for_index(index,x,y)
    return nil if index <= 0
    MapTile.new(y,x, index-1)
  end
end
