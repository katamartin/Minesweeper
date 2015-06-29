require_relative 'board'

class Game

  attr_reader :board

  def initialize
    @board = Board.new
  end

  def play_turn
    action, pos = prompt
    if action  == "r" 
      board[*pos].reveal
    else
      board[*pos].flag
    end

  end

  def prompt
    print "Do you want to flag \"f\" or reveal \"r\"? "
    action = gets.chomp
    until valid_action?(action)
      print "Please enter a valid action (f or r): "
      action = gets.chomp
    end
    print "Choose a position: "
    pos = gets.chomp.split(",").map(&:to_i)
    until valid_pos?(pos)
      print "Please enter a valid position: "
      pos = gets.chomp.split(",").map(&:to_i)
    end

    [action, pos]
  end

  def valid_action?(action)
    ["f", "r"].include?(action.downcase)
  end

  def valid_pos?(pos)
    pos.length == 2 && pos[0].between?(0,8) && pos[1].between?(0,8)
  end

end
