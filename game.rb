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
      store_time
      display_leaderboard
    else
      board.render_losing_board
    end
  end

  def store_time
    username = prompt_for("username")
    winners_lines = File.readlines('winners.txt').map(&:chomp)
    winners_and_scores = winners_lines.map{|line| line.split(", ")}
    winners_and_scores << [board.elapsed_time, username]
    winners_and_scores = winners_and_scores.sort_by{|el| el[0].to_i}[0..9]
    text = winners_and_scores.map {|el| el.join(", ")}.join("\n")
    File.open('winners.txt', 'w+') {|f| f.puts(text)}
  end

  def display_leaderboard
    system("clear")
    winners_lines = File.readlines('winners.txt').map(&:chomp)
    winners_and_scores = winners_lines.map{|line| line.split(", ")}
    puts "   LEADERBOARD:"
    puts "   Time (seconds), Username"
    winners_and_scores.each_with_index do |winner, idx|
      index = "#{idx + 1}".ljust(3)
      time = "#{winner[0].to_i}".ljust(16)
      name = "#{winner[1]}"
      puts "#{index}#{time}#{name}"
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
    filename = prompt_for("filename")
    board.elapsed_time += Time.now - board.start_time
    File.open("#{filename}.yaml", "w"){|f| f.puts(board.to_yaml)}
    abort("Saved to #{filename}.yaml")
  end

  def prompt_for(name)
    print "Please enter a #{name}: "
    input = gets.chomp
    until input.length > 0
      print "Please enter a valid #{name}: "
      input = gets.chomp
    end

    input
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
