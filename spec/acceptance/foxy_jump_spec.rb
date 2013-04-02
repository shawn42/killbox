require 'spec_helper'

class MockImage
  def width; 26; end
  def height; 30; end
end

class FakeLevel
  attr_accessor :named_objects
  def initialize
    @named_objects = {}
  end
end

Stage.definitions[:level_play].curtain_up do
  extend TestStageHelpers

  director.update_slots = [:first, :before, :update, :last]

  require 'tmx'
  map = Tmx::Map.new("#{APP_ROOT}/spec/fixtures/maps/basic_jump.tmx")

  map_data = LevelLoader::MapData.new
  map_data.tile_grid = LevelLoader.generate_map(map)[0]

  map_data.tileset_image = "map/tileset.png"
  # all tiles will be square!
  map_data.tile_size = 16
  
  map_actor = create_actor :map, map_data: map_data

  @level = FakeLevel.new
  @level.named_objects[:player1] = create_actor :foxy, map: map_actor, x: 120, y: 60

  setup_players
end

describe "Foxy jumping", acceptance: true do
  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    # mock_tiles 'foxy.png', 84/3, 360/9
    # mock_image 'foxy.png'
    # TEMP til we get new sprites
    mock_image 'boxy.png'
    mock_image 'bullet.png'
    mock_image 'bomb.png'
    Gamebox.configuration.stages = [:level_play]

    game
  end

  let(:floor_y) { 145 }
  let(:foxy_h) { 60 }
  let(:foxy_w) { 32 }

  let(:tile_size) { 16 }
  let(:map) { game.actor(:map) }
  let(:foxy) { game.actor(:foxy) }

  it 'jumps from floor to ceiling and back' do
    see_actor_attrs :foxy, 
      x: 120.ish

    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: floor_y.ish,
      rotation: 0.ish

    jump 2000
    update 1000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: (tile_size + foxy_h / 2.0 + 1).ish,
      rotation: 180.ish

    jump 2000
    update 2000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: floor_y.ish,
      rotation: 0.ish
  end

  it 'does not shoot self into floor' do
    # settle
    update 2000, step: 20

    press_key KbUp
    press_key KbB

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: floor_y.ish,
      rotation: 0.ish

  end

  it 'walks and rotates to wall' do
    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: floor_y.ish

    walk_left 1200

    see_actor_attrs :foxy, 
      on_ground: true,
      rotation: 90.ish,
      x: 47.ish

    foxy.y.should < floor_y

  end

  def walk_left(time_held)
    press_key KbA
    update time_held, step: 20
    release_key KbA
  end

  it 'grabs the wall when we rotate next to it' do
    start_x = tile_size + foxy_w / 2 + 1
    foxy.x = start_x

    see_actor_attrs :foxy, 
      x: start_x.ish

    # settle
    update 4000, step: 20

    see_actor_attrs :foxy, 
      x: start_x.ish,
      y: floor_y.ish,
      rotation: 0.ish

    jump 100
    update 1000, step: 20

    see_actor_attrs :foxy, 
      rotation: 90.ish,
      rotation_vel: 0.ish

  end

  context "shields up" do
    it 'does not get stuck when glancing off the wall' do
      start_x = tile_size + foxy_w / 2 + 1
      foxy.x = start_x

      see_actor_attrs :foxy, 
        x: start_x.ish

      # settle
      update 4000, step: 20

      see_actor_attrs :foxy, 
        x: start_x.ish,
        y: floor_y.ish,
        rotation: 0.ish

      foxy.when :vel do |old, n|
        binding.pry
      end

      jump 10
      update 20

      shields_up

      # wait for shields to wear off
      update 3000, step: 20

      # should now stick to the ceiling
      see_actor_attrs :foxy, 
        rotation: 180.ish,
        rotation_vel: 0.ish

      # bounced off the wall
      foxy.x.should > start_x

    end
  end

  context "bombs" do
    it 'does not blast you through the floor' do
      update 4000, step: 20

      see_actor_attrs :foxy, 
        x: 120.ish,
        y: floor_y.ish,
        rotation: 0.ish

      look_up
      10.times do
        charge_and_throw_bomb 50
        update 1
      end
      update 2500, step: 20
      shields_up

      update 1200, step: 20

      see_actor_attrs :foxy, 
        x: 120.ish,
        rotation: 0.ish

      foxy.y.should be < floor_y

    end
  end

  def jump(amount)
    # charge & jump
    press_key KbN
    update amount, step: 20
    release_key KbN
  end

  def charge_and_throw_bomb(time_held)
    press_key KbM
    update time_held, step: 20
    release_key KbM
  end

  def look_up
    press_key KbW
  end

  def shields_up
    press_key KbV
  end

end

