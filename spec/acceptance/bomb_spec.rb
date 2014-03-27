require 'spec_helper'


describe "Killbox bombing", acceptance: true do
  let(:zones) { KillboxAcceptanceHelpers.get_test_map("shooting").object_groups.detect{|og|og.name == "zones"}.objects.inject({}) do |h,x| h[x.name] = x; h; end }
  let(:floor_zone) { zones["floor"] }
  let(:right_wall_zone) { zones["right_wall"] }

  let(:tile_size) { 36 }
  let(:map) { game.actor(:map) }
  let(:player) { game.actor(:player) }
  let(:reticle) { game.actor(:reticle) }

  let(:player_w) { 32 }
  let(:player_h) { 60 }
  let(:bomb) { game.actor(:bomb) }
  let(:player) { game.actor(:player) }
  let!(:props) { mock_tiles 'trippers/props.png', 32, 32 }

  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    # mock_image 'boxy.png' # TODO: provide width and height as 2nd and third args
    # mock_image 'bullet.png'
    # mock_image 'bomb.png'

    configure_game_with_testing_stage  map_name: "shooting"

    # See player land standing where expected:
    see_player_is_standing_on_the_ground
  end

  describe 'throwing bombs' do
    context 'no aiming' do

      it 'throws right when looking right' do
        look_right
        throw_bomb
        see_bomb_is_right_of_player
      end

      it 'throws left when looking left' do
        look_left
        throw_bomb
        see_bomb_is_left_of_player
      end

      it 'throws up when looking up' do
        look_up
        throw_bomb
        see_bomb_is_above_player
      end

      it 'throws down when looking down' do
        look_down
        throw_bomb
        see_bomb_is_below_player
      end
    end

    describe 'aiming' do
      it 'can aim mid air and not throw crazy acos range error' do
        look_right
        press_key KbD
        update 100, step: 20
        hold_key KbN, 100, step: 20
        update 40, step: 20

        release_key KbD
        update 40, step: 20

        press_key KbD
        update 40, step: 20
        press_key KbM
        update 40, step: 20
      end

      it 'draws the reticle' do
        look_right
        see_no_reticle
        while_charging_bomb do
          see_reticle_is_right_of_player
        end
      end

      it 'reticle moves out as bomb throw charges' do
        look_right
        while_charging_bomb do
          last_reticle_position = reticle.position
          update 20
          see_reticle_position_right_of last_reticle_position
        end
      end

      it 'only shows reticle if there are bombs left' do
        look_right
        use_all_bombs
        while_charging_bomb do
          see_no_reticle
        end
      end

      it 'throw faster the longer you hold' do
        min_vel = bomb_velocity_from_min_throw
        max_vel = bomb_velocity_from_max_throw
        max_vel.magnitude.should > min_vel.magnitude
      end

      it 'can aim up/right' do
        look_right
        while_charging_bomb do
          aim_up
        end
        see_bomb_is_up_and_right_of_player
      end

      it 'can aim up/left' do
        look_left
        while_charging_bomb do
          aim_up
        end
        see_bomb_is_up_and_left_of_player
      end

      it 'can aim down/right' do
        look_right
        while_charging_bomb do
          aim_down
        end
        see_bomb_is_down_and_right_of_player
      end

      it 'can aim down/left' do
        look_left
        while_charging_bomb do
          aim_down
        end
        see_bomb_is_down_and_left_of_player
      end

      it 'locks to up when holding up'
      it 'locks to right when holding right'
      it 'locks to left when holding left'
    end

    def aim_up
      hold_key KbW, 40, step: 20
    end

    def aim_down
      hold_key KbS, 40, step: 20
    end

    def bomb_velocity_from_min_throw
      throw_bomb 1
      game.actors(:bomb).last.vel
    end

    def bomb_velocity_from_max_throw
      throw_bomb 1_000
      game.actors(:bomb).last.vel
    end

    def use_all_bombs
      20.times { throw_bomb }
    end

    def see_reticle_position_right_of(position)
      reticle.x.should > position.x
    end

    def while_charging_bomb(&blk)
      press_key KbM
      update 20
      yield
      release_key KbM
      update 20
    end

    def see_no_reticle
      reticle.should be
      reticle.visible.should be_false
    end

    def see_reticle_is_right_of_player
      reticle.should be
      reticle.x.should > player.x
      reticle.visible.should be_true
    end

    def see_bomb_is_up_and_right_of_player
      see_bomb_is_right_of_player
      see_bomb_is_above_player
    end

    def see_bomb_is_up_and_left_of_player
      see_bomb_is_left_of_player
      see_bomb_is_above_player
    end

    def see_bomb_is_down_and_right_of_player
      see_bomb_is_right_of_player
      see_bomb_is_below_player
    end

    def see_bomb_is_down_and_left_of_player
      see_bomb_is_left_of_player
      see_bomb_is_below_player
    end

    def see_bomb_is_right_of_player
      bomb.x.should > player.x
    end

    def see_bomb_is_left_of_player
      bomb.x.should < player.x
    end

    def see_bomb_is_above_player
      bomb.y.should < player.y
    end
    
    def see_bomb_is_below_player
      bomb.y.should > player.y
    end
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

