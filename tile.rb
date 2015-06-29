#require_relative 'board.rb'

class Tile
  attr_accessor :bombed, :flagged, :revealed, :position, :neighbors

  DIRECTIONS = [
    [1, 0],
    [0, 1],
    [1, 1],
    [-1, 1],
    [-1, 0],
    [-1, -1],
    [0, -1],
    [1, -1]
  ]

  def initialize(board = nil, pos)
    @board = board
    @bombed = false
    @flagged = false
    @revealed = false
    @position = pos
    @neighbors = get_neighbors
  end

  def reveal
    @revealed = true unless flagged
  end

  def inspect
    if flagged
      return "⚐"
    elsif revealed
      return neighbor_count
    else
      "*"
    end

  end

  def neighbor_count
    count = 0
    neighbors.each do |neighbor|
      if board[*neighbor].bombed
        count += 1
      end
    end
    if count == 0
      return "_"
    else
      return count
    end
    
  end

  def get_neighbors
    neighbors = []
    DIRECTIONS.each do |direction|
      neighbor = [position[0] + direction[0], position[1] + direction[1]]
      neighbors << neighbor if neighbor.all? { |coord| coord.between?(0, 8) }
    end
    neighbors
  end

end
