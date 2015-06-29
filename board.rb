require_relative 'tile.rb'

class Board

  attr_reader :grid, :bombed_positions


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
    @bombed_positions = pick_bomb_positions
    grid.each_with_index do |row, idx1|
      row.each_with_index do |el, idx2|
        tile = Tile.new(self, [idx1, idx2])
        self[idx1, idx2] = tile
        tile.bombed = true if bombed_positions.include?([idx1, idx2])
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

  def render
    puts "  #{(0..8).to_a.join(" ")}"
    grid.each_with_index do |row, i|
      puts "#{i} #{row.join(" ")}"
    end
  end

  def render_losing_board
    bombed_positions.each do |pos|
      board[*pos].flagged = false
      board[*pos].reveal
    end
    render
  end

end

b = Board.new
b.render
b[0,0].reveal
b.render
