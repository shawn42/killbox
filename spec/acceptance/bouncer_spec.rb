require 'spec_helper'


describe "Killbox tile bouncing", acceptance: true do
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

  describe 'bouncing' do
    it 'does not crash' do
      5.times { drop_da_bomb }
      5.times { place_land_mine }

      little_jump

      shields_up

      update 4000, step: 20
    end
  end

  def little_jump
    jump 300
    update 20
  end

  def drop_da_bomb
    throw_bomb 10
  end

  def aim_up(hold_time=40)
    hold_key KbW, hold_time, step: 20
  end

  def aim_down
    hold_key KbS, 40, step: 20
  end

  def see_player_is_standing_on_the_ground
    update 2000, step: 20
    see_actor_attrs :player,
      rotation: 0.ish,
      on_ground: true
    see_bottom_right_standing_above floor_zone.y
    see_bottom_left_standing_above floor_zone.y
  end



end
