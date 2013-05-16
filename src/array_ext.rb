class Array
  def average
    inject(:+) / size
  end
end
