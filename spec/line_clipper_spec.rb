require_relative 'spec_helper'

describe LineClipper do
  describe ".cohen_sutherland_line_clip" do
    it 'clips a line that intersects' do
      clip_box = Rect.new 5, 0, 10, 10
      LineClipper.cohen_sutherland_line_clip(0, 0, 10, 0, clip_box).should == 
        [5, 0, 10, 0]
    end

    it 'true if line is completely contained' do
      clip_box = Rect.new 0, 0, 10, 10
      LineClipper.cohen_sutherland_line_clip(1, 1, 9, 9, clip_box).should == true
    end

    it 'false if line does not collide' do
      clip_box = Rect.new 0, 0, 10, 10
      LineClipper.cohen_sutherland_line_clip(11, 11, 19, 19, clip_box).should be_false
    end
  end
end
