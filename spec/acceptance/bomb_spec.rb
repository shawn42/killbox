require 'spec_helper'


describe "Killbox bombing", acceptance: true do
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

    configure_game_with_testing_stage  map_name: "shooting"

    # See player land standing where expected:
    see_player_is_standing_on_the_ground
  end

  describe 'land mines' do
    it 'can place and arm a land mine' do
      place_land_mine
      see_no_bombs_were_set
      see_land_mine_was_placed_at_players_feet

      move_player_away
      wait_for_land_mine_to_arm
    end

    it 'blows up via player proximity' do
      place_land_mine
      move_player_away
      wait_for_land_mine_to_arm

      see_land_mine_does_not_blow_up_on_its_own

      move_player_to_land_mine

      see_land_mine_blew_up
      player.should_not be_alive
    end

    it 'can be shot' do
      place_land_mine
      jump_to_ceiling
      shoot_land_mine_above_us

      see_land_mine_blew_up
    end
  end

  def see_player_is_standing_on_the_ground
    update 2000, step: 20
    see_actor_attrs :player, 
      rotation: 0.ish,
      on_ground: true
    see_bottom_right_standing_above floor_zone.y
    see_bottom_left_standing_above floor_zone.y
  end

  def see_land_mine_blew_up
    game.actors(:land_mine).should be_empty
  end

  def shoot_land_mine_above_us
    look_up
    shoot
    update 4000, step: 20
  end

  def jump_to_ceiling
    jump 1000
    update 4000
  end

  def move_player_away
    player.x += 300
  end

  def move_player_to_land_mine
    player.x -= 300
    update 1000, step: 20
  end

  def wait_for_land_mine_to_arm
    update 3000, step: 20
    see_actor_attrs :land_mine,
      armed: true
  end

  def see_land_mine_does_not_blow_up_on_its_own
    update 10_000, step: 20
    see_actor_attrs :land_mine,
      armed: true
  end

  def see_no_bombs_were_set
    game.actors(:bomb).should be_empty
  end

  def see_land_mine_was_placed_at_players_feet
    see_actor_attrs :land_mine,
      armed: false,
      x: player.x.ish,
      y: (floor_zone.y - 1).ish

  end

end

