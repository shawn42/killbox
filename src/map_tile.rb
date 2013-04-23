class MapTile
  attr_accessor :row, :col, :gfx_index
  def initialize(row,col,index=-1)
    @row=row
    @col=col
    @gfx_index = index
  end

  def to_s
    "#{super} col: #{@col} row: #{@row} gfx: #{@gfx_index}"
  end
end
