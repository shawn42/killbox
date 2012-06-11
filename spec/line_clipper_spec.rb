require_relative 'spec_helper'

describe LineClipper do
  describe ".cohen_sutherland_line_clip" do
    it 'clips a line that intersects' do
      clip_box = Rect.new 5, 0, 10, 10
      LineClipper.cohen_sutherland_line_clip(0, 0, 10, 0, clip_box).should == 
        [5, 0, 10, 0]
    end
  end
end
