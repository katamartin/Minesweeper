require_relative 'tile.rb'
require 'yaml'

class Board
  attr_reader :grid, :bombed_positions

  def initialize
    @grid = Array.new(9) {Array.new(9)}
    populate
  end

  def self.from_file(filename)
    YAML.load_file(filename)
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
      pos = [rand(9), rand(9)]
      bomb_positions << pos unless bomb_positions.include?(pos)
    end

    bomb_positions
  end

  def render
    system("clear")
    puts "  #{(0..8).to_a.join(" ")}"
    grid.each_with_index do |row, i|
      puts "#{i} #{row.join(" ")}"
    end
  end

  def render_losing_board
    system("clear")
    bombed_positions.each do |pos|
      self[*pos].flagged = false
      self[*pos].reveal
    end
    render
    puts "Game over!"
  end

  def over?
    bomb_revealed? || won?
  end

  def bomb_revealed?
    bombed_positions.any?{|pos| self[*pos].revealed}
  end

  def won?
    grid.each_with_index do |row, row_num|
      row.each_with_index do |tile, col_num|
        return false if tile.revealed && tile.bombed
        return false if !tile.revealed && !tile.bombed
      end
    end

    true
  end
end
