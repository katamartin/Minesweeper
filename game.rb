require_relative 'board'
require 'yaml'
require 'io/console'

class Game
  attr_reader :board

  def initialize
    filename = prompt_for_load
    @board = filename ? Board.from_file(filename) : Board.new
    play
  end

  def play
    until board.over?
      board.display
      make_move
    end
    if board.won?
      board.display
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

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def make_move
    move_made = false
    until move_made
      move_made = move_highlight
    end
  end

  def move_highlight
    c = read_char
    case c
    when "\e[A"
      board.move_highlight([-1, 0])
    when "\e[B"
      board.move_highlight([1, 0])
    when "\e[C"
      board.move_highlight([0, 1])
    when "\e[D"
      board.move_highlight([0, -1])
    when "r"
      board[*board.highlighted].reveal
      return true
    when "f"
      board[*board.highlighted].flag
      return true
    when "q"
      save_and_quit
    end
    system("clear")
    board.display
    false
  end

end

if $PROGRAM_NAME == __FILE__
  Game.new()
end
