# TODO build this from yaml or hash
class Colors
  def self.pink
    Color.argb(255, 222, 135, 170).dup
  end

  def self.gray
    Color.argb(255, 98, 98, 98).dup
  end
end

class Color
  def fade(percentage=0.2)
    self.alpha = (255*percentage)
    self
  end
end

