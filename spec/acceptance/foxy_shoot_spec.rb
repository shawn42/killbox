require 'spec_helper'


describe "Foxy shooting", acceptance: true do
  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    # mock_tiles 'foxy.png', 84/3, 360/9
    # mock_image 'foxy.png'
    # TEMP til we get new sprites
    mock_image 'boxy.png' # TODO: provide width and height as 2nd and third args
    mock_image 'bullet.png'
    mock_image 'bomb.png'
    Gamebox.configuration.stages = [:level_play]

    Stage.definitions[:level_play].curtain_up do
      extend TestStageHelpers

      director.update_slots = [:first, :before, :update, :last]

      tmx_map = FoxyAcceptanceHelpers.get_test_map("shooting")
      map_data = LevelLoader::MapData.new
      map_data.tile_grid = LevelLoader.generate_map(tmx_map)[0]

      map_data.tileset_image = "map/tileset.png"
      # all tiles will be square!
      map_data.tile_size = 36
      
      # map_actor = create_actor :map, map_data: map_data

      @level = FakeLevel.new
      @level.map = self.create_actor :map, map_data: map_data
      @level.map_extents = [0,0, map_data.tile_grid[0].size * map_data.tile_size, map_data.tile_grid.size * map_data.tile_size]
      # @level.named_objects[:player1] = create_actor :foxy, map: map_actor, x: 120, y: 60

      LevelLoader.load_objects self, tmx_map, @level

      setup_players
    end

    game
  end
  let(:zones) { FoxyAcceptanceHelpers.get_test_map("shooting").object_groups["zones"].inject({}) do |h,x| h[x[:name]] = x; h; end }
  let(:floor_zone) { zones["floor"] }
  let(:right_wall_zone) { zones["right_wall"] }

  let(:tile_size) { 36 }
  let(:map) { game.actor(:map) }
  let(:foxy) { game.actor(:foxy) }

  let(:foxy_w) { 32 }
  let(:foxy_h) { 60 }

  it 'shoots to the right' do

    # settle
    update 2000, step: 20

    see_actor_attrs :foxy, 
      gun_direction: vec2(1,0), # gun pointing right
      x: 504.ish, # as placed in shooting.tmx
      rotation: 0.ish

    see_bottom_right_standing_above floor_zone[:y]
    see_bottom_left_standing_above floor_zone[:y]

    shoot

    bullet = game.actor(:bullet)

    bullet.should be # bullet exists
    bullet.x.should > foxy.x # bullet is to the right of foxy about middle-high and traveling right
    last_bullet_x = bullet.x
    bullet.y.should == foxy.y.ish
    bullet.vel.angle.should == 0.ish
    bullet.vel.magnitude.should > 1 # don't want to be assertive about exact speed, just that it's going

    # after a half second, the bullet is further to the right at precisely same height
    update 250, step: 20
    bullet.should be_alive
    bullet.x.should > last_bullet_x
    bullet.y.should == foxy.y.ish

    # the bullet should hit the far-right wall and disappear
    ticks = 0 # safety catch on test
    while bullet.alive? && ticks < 1000
      update 20
      ticks += 1
    end
    bullet.should_not be_alive
    bullet.x.should == right_wall_zone[:x].ish(15)
  end

end

