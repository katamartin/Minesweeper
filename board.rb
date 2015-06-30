require_relative 'tile.rb'
require 'yaml'
require 'colorize'

class Board
  attr_reader :grid, :bombed_positions
  attr_accessor :start_time, :elapsed_time, :highlighted

  def initialize
    @grid = Array.new(9) {Array.new(9)}
    populate
    @start_time = Time.now
    @elapsed_time = 0
    @highlighted = [0, 0]
  end

  def self.from_file(filename)
    board = YAML.load_file(filename)
    board.start_time = Time.now
    board
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


  def display
    system("clear")
    (0..8).each do |row|
      (0..8).each do |col|
        if [row, col] == highlighted
          print "#{self[row,col]}".colorize(:background => :red)
        else
          print "#{self[row, col]}"
        end
        print " "
      end
      puts ""
    end
    puts "Navigate using arrow keys."
    puts "Press \"r\" to reveal, \"f\" to flag, or \"q\" to save and quit."
  end

  def render_losing_board
    system("clear")
    bombed_positions.each do |pos|
      self[*pos].flagged = false
      self[*pos].reveal
    end
    display
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

    self.elapsed_time += Time.now - start_time
    true
  end

  def move_highlight(dx)
    new_highlight = [self.highlighted[0] + dx[0], self.highlighted[1] + dx[1]]
    self.highlighted = new_highlight if new_highlight.all? { |x| x.between?(0, 8) }
  end

end
