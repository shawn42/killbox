require_relative 'spec_helper'

describe LineClipper do
  describe ".cohen_sutherland_line_clip" do
    it 'clips a line that along the top edge' do
      clip_box = Rect.new 5, 0, 12, 8
      LineClipper.cohen_sutherland_line_clip(0, 0, 10, 0, clip_box).should == 
        [5, 0, 10, 0]
    end

    it 'clips a left-going line that intersects on the right edge' do
      clip_box = Rect.new 5.2, 0, 12.5, 8
      LineClipper.cohen_sutherland_line_clip(18, 4, 10, 8, clip_box)[0].should == 17.7
    end

    it 'clips a right-going line that intersects on the left edge' do
      clip_box = Rect.new 5.2, 0, 12, 8
      LineClipper.cohen_sutherland_line_clip(2.8, 4, 10, 8, clip_box)[0].should == clip_box[0]
    end

    it 'clips a right-going line that passes through' do
      clip_box = Rect.new 5.2, 0, 12, 8
      spot = LineClipper.cohen_sutherland_line_clip(2.8, 4, 18, 8, clip_box)
      spot[0].should == clip_box[0]
      spot[2].should == clip_box.right
    end

    it 'returns a line that touches' do
      clip_box = Rect.new 5, 0, 10, 10
      LineClipper.cohen_sutherland_line_clip(3, 0, 5, 0, clip_box).should == 
        [5, 0, 5, 0]
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
