class MapTile
  attr_accessor :row, :col, :gfx_index
  def initialize(row,col,index=-1)
    @row=row
    @col=col
    @gfx_index = index
  end
end
