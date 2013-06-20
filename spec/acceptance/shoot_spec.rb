require 'spec_helper'


describe "Killbox shooting", acceptance: true do
  let(:zones) { KillboxAcceptanceHelpers.get_test_map("shooting").object_groups.detect{|og|og.name == "zones"}.objects.inject({}) do |h,x| h[x.name] = x; h; end }
  let(:floor_zone) { zones["floor"] }
  let(:right_wall_zone) { zones["right_wall"] }

  let(:tile_size) { 36 }
  let(:map) { game.actor(:map) }
  let(:player) { game.actor(:player) }

  let(:player_w) { 32 }
  let(:player_h) { 60 }

  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    mock_image 'boxy.png' # TODO: provide width and height as 2nd and third args
    mock_image 'bullet.png'
    mock_image 'bomb.png'

    configure_game_with_testing_stage  map_name: "shooting", player_count: 2

    # See player land standing where expected:
    update 2000, step: 20
    see_actor_attrs :player, 
      x: 504.ish, # as placed in shooting.tmx
      rotation: 0.ish
    see_bottom_right_standing_above floor_zone.y
    see_bottom_left_standing_above floor_zone.y
  end

  it 'can shoot another player' do
    players = game.actors(:player)
    players.size.should == 2

    player1 = players[0]
    player2 = players[1]

    player2.x += 200

    look_right
    shoot
    update 1000, step: 20

    player2.should_not be_alive
    game.actors(:player).size.should == 1
  end

  it 'does not snap strangle when shield wears off' do
    # TODO setup movement spec to use a new map
    # then move this spec back
    max_x = player.x
    player.when :x_changed do
      max_x = player.x if player.x > max_x
    end

    # get going
    press_key KbD
    update 1000, step: 20

    shields_up
    update 20
    release_key KbD
    # should keep floating right
    # what for shields to wear off
    update 1300, step: 20

    see_bottom_right_standing_above floor_zone.y
    see_bottom_left_standing_above floor_zone.y
    player.x.should >= max_x
  end


  it 'shoots to the right' do
    see_actor_attrs :player, gun_direction: vec2(1,0) # gun pointing right

    shoot

    bullet = game.actor(:bullet)

    bullet.should be # bullet exists
    bullet.x.should > player.x # bullet is to the right of player about middle-high and traveling right
    last_bullet_x = bullet.x
    bullet.y.should == player.y.ish
    bullet.vel.angle.should == 0.ish
    bullet.vel.magnitude.should > 1 # don't want to be assertive about exact speed, just that it's going

    # after a half second, the bullet is further to the right at precisely same height
    update 250, step: 20
    bullet.should be_alive
    bullet.x.should > last_bullet_x
    bullet.y.should == player.y.ish

    # the bullet should hit the far-right wall and disappear
    ticks = 0 # safety catch on test
    while bullet.alive? && ticks < 1000
      update 20
      ticks += 1
    end
    bullet.should_not be_alive
    bullet.x.should == right_wall_zone.x.ish(15)
  end

    it 'shoots at the correct angle when floating/spinning' do
      # Jump and begin tumbling counter-clockwise, pausing at -15 degrees:
      jump 1000
      ticks = 0 # prevent infinite loop
      while player.rotation > -15 && ticks < 250
        update 20
        ticks += 1
      end
      player.rotation.should <= -15

      # Now fire
      shoot
      
      bullet = game.actor(:bullet)
      bullet.should be # bullet exists

      bullet_start_x = bullet.x
      bullet_start_y = bullet.y

      # See the bullet trajectory matches player's rotation:
      radians_to_degrees(bullet.vel.angle).should == -15.ish

      # sanity-check vector alignment: should be a straight line from player's center, through the gun tip, to the bullet.
      # (Ie, the vector angles need to be the same)
      player_vector             = body_vector(player)
      original_gun_tip_vector = body_vector(player.gun_tip)
      bullet_vector           = body_vector(bullet)
      player_to_bullet          = bullet_vector - player_vector
      player_to_gun_tip         = original_gun_tip_vector - player_vector
      gun_tip_to_bullet       = bullet_vector - original_gun_tip_vector

      player_to_gun_tip.angle.should == player_to_bullet.angle.ish

      # See the rotation stays correct over time:
      update 100, step: 20
      radians_to_degrees(bullet.vel.angle).should == -15.ish
      bullet.x.should > bullet_vector.x # bullet should have moved right
      bullet.y.should < bullet_vector.y # bullet should have moved up

      # See that a vector from the original gun tip to the new bullet matches the angle of the original gun_tip_to_bullet
      new_bullet_vector = body_vector(bullet)
      original_gun_tip_to_new_bullet_vector = new_bullet_vector - original_gun_tip_vector
      original_gun_tip_to_new_bullet_vector.angle.should == gun_tip_to_bullet.angle.ish
    end

end

