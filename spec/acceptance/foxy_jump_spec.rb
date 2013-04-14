require 'spec_helper'


describe "Foxy jumping", acceptance: true do
  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    mock_image 'boxy.png'
    mock_image 'bullet.png'
    mock_image 'bomb.png'

    configure_game_with_testing_stage map_name: "basic_jump", tile_size: 16
  end

  let(:floor_y) { 145 }
  let(:foxy_h) { 60 }
  let(:foxy_w) { 32 }

  let(:tile_size) { 16 }
  let(:map) { game.actor(:map) }
  let(:foxy) { game.actor(:foxy) }

  it 'walks over gaps in the floor (does not switch planes)' do
    see_actor_attrs :foxy, 
      x: 120.ish

    # settle
    # log "WAITING"
    update 3000, step: 20
    # log "SETTLED"

    see_actor_attrs :foxy, 
      x: 120.ish,
      y: floor_y.ish,
      rotation: 0.ish

    count = 0
    while foxy.on_ground? && count < 1000
      # there's a hole 7 tiles from the left
      break unless foxy.on_ground
      count += 1
      walk_right 10
    end
    update 3000, step: 20

    see_actor_attrs :foxy, 
      y: floor_y.ish,
      rotation: 0.ish

    foxy.x.should > 120
  end

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

    look_up
    shoot

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

  def jump(time_held)
    # charge & jump
    hold_key KbN, time_held, step: 20
  end

  def charge_and_throw_bomb(time_held)
    hold_key KbM, time_held, step: 20
  end

  def walk_left(time_held)
    hold_key KbA, time_held, step: 20
  end

  def walk_right(time_held)
    hold_key KbD, time_held, step: 20
  end

  def look_up
    press_key KbW
  end

  def shields_up
    press_key KbV
  end

  def hold_key(key, time_held, opts={})
    press_key key
    update time_held, step: opts[:step]
    release_key key
  end

end

