require 'spec_helper'


describe :tile_collision_detector do

  def empty_actor
    Actor.new(this_object_context: mock)
  end

  def create_mocks(*args)
    {}.tap do |mocks|
      args.each do |mock_name|
        the_mock = send(mock_name) if respond_to?(mock_name)

        # the_mock = instance_variable_get("@#{mock_name}")
        the_mock ||= mock(mock_name.to_s)
        # instance_variable_set "@#{mock_name}", the_mock
        self.class.let(mock_name.to_sym) { the_mock }
        mocks[mock_name.to_sym] = the_mock
      end
    end
  end

  before { 
    @_beh_mock_names = Behavior.object_definition.component_names
    @_mocks_created = create_mocks *@_beh_mock_names

    @behavior_definition = Behavior.definitions[:tile_collision_detector]
    reqs = @behavior_definition.required_injections || []
    reqs -= @_beh_mock_names
    @_req_mocks = create_mocks(*reqs)
  }
  let (:opts) { {} }

  subject { 
    # TODO so much duplication here from the *Factories
    Behavior.new(@_mocks_created).tap do |behavior|
      @_req_mocks.keys.each do |req|
        object = @_req_mocks[req]
        behavior.define_singleton_method req do
          components[req] 
        end
        components = behavior.send :components
        components[req] = object
      end

      helpers = @behavior_definition.helpers_block
      if helpers
        helpers_module = Module.new &helpers
        behavior.extend helpers_module
      end

      behavior.define_singleton_method :react_to, @behavior_definition.react_to_block if @behavior_definition.react_to_block

      # TODO not sure the right way to mock this out
      # deps = @behavior_definition.required_behaviors
      # if deps
      #   deps.each do |beh|
      #     _add_behavior actor, beh unless actor.has_behavior?(beh)
      #   end
      # end
      behavior.opts = opts
      behavior.instance_eval &@behavior_definition.setup_block if @behavior_definition.setup_block
    end
  }


  # subjectify_behavior(:tile_collision_detector)

  let!(:actor) { empty_actor }
  let(:director) { evented_stub(mock('director')) }
  let(:tile_size) { 16 }
  let(:grid) { [
    [nil, 1 ,nil],
    [nil,nil,nil],
    [nil,nil, 1 ],
  ]}
  let(:map) { stub('map', map_data: :some_map_data) }

  describe "a single point object" do
    before do
      actor.has_attributes vel: vec2(0,0), 
                 bb: Rect.new(0,0,10,10), 
                 predicted_bb: Rect.new(0,0,10,10), 
                 vel: vec2(5,0),
                 map: map,
                 position: vec2(5,5),
                 rotation: 0,
                 collision_point_deltas: [vec2(0,0)],
                 collision_points: [vec2(5,5)]
    end

    it 'fires empty if there are no tile overlaps' do
      subject
      map_inspector.expects(:overlap_tiles).with(:some_map_data, anything)
      expects_event actor, :tile_collisions, [] do
        director.fire :update, 1
      end
    end

    it 'emits w/ data when there is a basic left collision' do
      pending
      actor.position = vec2(12,5)
      actor.vel = vec2(5,0)
      subject
      
      expects_event actor, :tile_collisions, [[[{row: 0, col: 1, tile_face: :left, hit: [16.ish, 5.0.ish, 17.0.ish, 5.0.ish], point_index: 0, tile_bb: tile_bb_for(1,0)}]]] do
        director.fire :update, 1
      end
    end

    it 'emits w/ data when with collision on the corner' do
      pending
      actor.position = vec2(30, 30)
      actor.bb = Rect.new(25,25,35,35)
      actor.vel = vec2(4.1,4.1)
      subject
      
      expects_event actor, :tile_collisions, [[[{row: 2, col: 2, tile_face: :top, 
        hit: [32, 32, 34.1, 34.1].ish, point_index: 0, tile_bb: tile_bb_for(2,2)}]]] do
        director.fire :update, 1
      end
    end
  end

  describe "a player-like object at glancing angle" do
    let(:grid) { [[nil,nil, 1]] * 8 }
    before do
      actor.has_attributes vel: vec2(0,-4), 
                           bb: Rect.new(0,0,16*3,16*8), 
                           map: map,
                           position: vec2(17, 65),
                           rotation: 0.0,
                           rotation_vel: -3,
                           width: 28,
                           height: 40,
                           collision_point_deltas: [
                             vec2(-14.0, -20.0), 
                             vec2(14.0, -20.0), 
                             vec2(14.0, -10.0), 
                             vec2(14.0, 10.0), 
                             vec2(14.0, 20.0), 
                             vec2(-14.0, 20.0), 
                             vec2(-14.0, 10.0), 
                             vec2(-14.0, -10.0)]
    end

    it 'does not get stuck on a wall' do
      pending
      subject
      
      expects_event actor, :tile_collisions, [[[{row: 5, col: 2, tile_face: :left, hit: 
        [32, 80.367, 32.027, 80.239].ish, point_index: 4, tile_bb: tile_bb_for(2, 5)}]]] do
      director.fire :update, 1
      end
    end
  end

  def tile_bb_for(col, row)
    [col*tile_size, row*tile_size, tile_size, tile_size].ish
  end


end
