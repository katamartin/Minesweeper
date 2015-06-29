require_relative 'board'
require 'yaml'

class Game
  attr_reader :board

  def initialize
    filename = prompt_for_load
    @board = filename ? Board.from_file(filename) : Board.new
    play
  end

  def play
    until board.over?
      board.render
      play_turn
    end
    if board.won?
      board.render
      puts "Congrats! You win!"
    else
      board.render_losing_board
    end
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
    print "Do you want to flag \"f\", reveal \"r\", or save and quit \"q\"? "
    action = gets.chomp
    until valid_action?(action)
      print "Please enter a valid action (f or r or q): "
      action = gets.chomp
    end
    if action == "q"
      return save_and_quit
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
    ["f", "r", "q"].include?(action.downcase)
  end

  def valid_pos?(pos)
    pos.length == 2 && pos.all? { |coord| coord.between?(0,8) }
  end

  def save_and_quit
    time_stamp = Time.now.to_s[0..18]
    File.open("#{time_stamp}.yaml", "w"){|f| f.puts(board.to_yaml)}
    abort("Saved to #{time_stamp}.yaml")
  end

  def prompt_for_load
    print "Do you want to load from file (y/n)? "
    action = gets.chomp.downcase
    until action == "y" || action == "n"
      print "Please choose either \"y\" or \"n\":"
      action = gets.chomp.downcase
    end
    return nil if action == "n"

    print "Please enter the filename to load: "

    filename = gets.chomp.downcase
  end

end

if $PROGRAM_NAME == __FILE__
  Game.new()
end
