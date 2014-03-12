# TODO update HashTree#[] to return a HashTreeNode that holds its relative path
#      p1 = tree[:player1]
#      p1.set_value_for_path KbV, subpath1, subpath2
class HashTree
  def initialize(initial_hash={})
    @storage = initial_hash
  end
  
  def set_value_for_path(value, *path_pieces)
    current_path = @storage
    last_piece = path_pieces.pop
    path_pieces.each do |piece|
      current_path = current_path[piece] ||= {} 
    end
    current_path[last_piece] = value
  end

  def get_value_for_path(*path_pieces)
    current_path = @storage
    path_pieces.each do |piece|
      current_path = current_path[piece]
    end

    current_path
  end

end

