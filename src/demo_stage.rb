class DemoStage < Stage
  def setup
    super
    create_actor :fps, x:10, y:10
    @foxy = create_actor :foxy, x: 100, y:300
  end
end

