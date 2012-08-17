class LevelLoader
  class Level
    attr_accessor :map, :objects, :foxy_info, :named_objects, :map_extents
  end

  class MapData
    attr_accessor :tiles, :tile_grid, :tileset_image, :tile_size
  end

  def self.load(stage, level_indicator)
    require 'tmx'
    # map = Tmx::Map.new("#{APP_ROOT}/data/maps/level_#{level_indicator.world}_#{level_indicator.level}.tmx")
    map = Tmx::Map.new("#{APP_ROOT}/data/maps/advanced_jump.tmx")

    map_data = MapData.new
    map_data.tiles, map_data.tile_grid = generate_map(map)
    map_data.tileset_image = "map/tileset.png"
    # all tiles will be square!
    map_data.tile_size = 16
    
    Level.new.tap do |level|
      level.map = stage.create_actor :map, map_data: map_data
      level.map_extents = [0,0, 
        map_data.tile_grid[0].size * map_data.tile_size, map_data.tile_grid.size * map_data.tile_size]

      load_objects stage, map, level
    end
  end

  # TODO
  def self.generate_map(map)
    layer = map.layers["terrain"]

    #
    # Main map
    #
    tiles = []
    tile_grid = []
    layer.rows.times do 
      tile_grid << [nil]*layer.columns
    end

    layer.each_tile_id do |x,y, tile_id|
      tile = new_tile_for_index(tile_id, x,y)
      tiles << tile
      tile_grid[y][x] = tile
    end

    return tiles, tile_grid
  end

  def self.load_objects(stage, map, level)
    level.objects = []
    level.named_objects = {}

    map.object_groups.values.each do |obj_group|
      obj_group.each do |obj|
        if obj[:type]
          actor = stage.create_actor(obj[:type].to_sym, obj.merge(
            session: stage.session,
            map: level.map
          ))
          
          name = obj[:name]
          level.named_objects[name.to_sym] = actor if name
          level.objects << actor
        end
      end
    end

    raise "FAILED TO LOAD FOXYS INFO" unless level.named_objects.has_key? :foxy

  end

  def self.new_tile_for_index(index,x,y)
    return nil if index <= 0
    MapTile.new(y,x, index-1)
  end
end
