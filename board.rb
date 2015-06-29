require_relative 'tile.rb'

class Board

  attr_reader :grid


  def initialize(filename = nil)
    @grid = Array.new(9) {Array.new(9)}
    populate
  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, value)
    @grid[row][col] = value
  end



  def populate
    bomb_positions = pick_bomb_positions
    grid.each_with_index do |row, idx1|
      row.each_with_index do |el, idx2|
        tile = Tile.new(self, [idx1, idx2])
        self[idx1, idx2] = tile
        tile.bombed = true if bomb_positions.include?([idx1, idx2])
      end
    end
  end

  def pick_bomb_positions
    bomb_positions = []
    until bomb_positions.length == 9
      pos = [(0..8).to_a.sample, (0..8).to_a.sample]
      bomb_positions << pos unless bomb_positions.include?(pos)
    end
    bomb_positions
  end

end

b = Board.new
p b
