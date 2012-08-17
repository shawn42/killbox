require 'spec_helper'

describe "Foxy can jump and land", acceptance: true do

  it 'can jump and land' do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    mock_tiles 'foxy.png', 84/3, 360/9
    mock_image 'foxy.png'
    tile_size = 16

    game.stage do |stage|
      director.update_slots = [:first, :before, :update, :last]
      require 'tmx'
      map = Tmx::Map.new("#{APP_ROOT}/spec/fixtures/maps/basic_jump.tmx")

      map_data = LevelLoader::MapData.new
      map_data.tiles, map_data.tile_grid = LevelLoader.generate_map(map)
      map_data.tileset_image = "map/tileset.png"
      # all tiles will be square!
      map_data.tile_size = tile_size
      
      map_actor = create_actor :map, map_data: map_data

      create_actor :foxy, map: map_actor, x: 120, y: 60
    end
    map = game.actor(:map)
    foxy = game.actor(:foxy)

    # settle
    100.times do
      update 20
    end

    foxy.rot.should be_within(0.001).of(0)

    see_actor_attrs :foxy, 
      x: 120,
      y: 165
      # y: 11 * tile_size - 20

    # charge & jump
    press_key KbUp
    10.times do 
      update 10
    end
    release_key KbUp

    # float through space
    100.times do
      update 10
    end

    # land
    # TODO some clever way of doing approx matches with see_actor_attrs
    normalize_angle(foxy.rot).should be_within(0.001).of(180)
    foxy.y.should be_within(0.001).of(tile_size + foxy.height / 2.0 + 1)

    see_actor_attrs :foxy,
      x: 120

  end
end

