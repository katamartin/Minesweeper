#require_relative 'board.rb'

class Tile
  attr_accessor :bombed, :flagged, :revealed, :position, :neighbors
  attr_reader :board

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

  def initialize(board, pos)
    @board = board
    @bombed = false
    @flagged = false
    @revealed = false
    @position = pos
    @neighbors = get_neighbors
  end

  def reveal
    self.revealed = true unless flagged
    if neighbor_count == "_" && !bombed
      neighbors.each do |neighbor|
        neighbor_tile = board[*neighbor]
        neighbor_tile.reveal unless neighbor_tile.revealed
      end
    end
  end

  def flag
    self.flagged = !flagged unless revealed
  end

  def inspect
    if flagged
      return "⚐"
    elsif revealed
      return "💣" if bombed
      return neighbor_count
    else
      "*"
    end
  end

  def to_s
    inspect.to_s
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
