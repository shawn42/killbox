define_behavior :pulled_by_black_hole do
  requires :black_hole_coordinator

  setup do
    black_hole_coordinator.register_pullable actor
  end

  remove do
    black_hole_coordinator.unregister_pullable actor
  end
end
