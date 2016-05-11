require 'yaml'
require_relative './lib/gallows'

class Hangman
  include Gallows
  def initialize
    @dictionary_path = "./lib/5desk.txt"
    @limit = 10
    @save_directory = "save_state.yaml"
    @password = choose_password.split(//)  # array of correct letters
    @guessing_board = @password.map { "_" } # current board and correct guesses    
    @incorrect_guesses = []  # prevent duplicates
    main_menu
  end
  
  protected
  
  def game_start
    while @limit > 0
      status = continue_guessing
      if status
        draw_board
        puts "Congratulations, you win! (Application will be closed in 3 seconds)"
        sleep(3)
        break
      else
        puts "Incorrect guesses left: #{@limit}"
      end
    end
    if @limit == 0
      draw_gallows (0)
      puts "You lose!"
      puts "The correct word was: #{@password.join}"
    end
  end
  
  private

  def main_menu
    draw_title
    puts "\n1 New Game"
    puts "2 Load Game"
    puts "3 Exit"
    choice = get_mode
    case choice
    when "1"
      self.game_start
    when "2"
      load_game
    when "3"
      abort "See you soon!"
    end
  end
  
  def get_mode
    choice = gets.chomp
    until choice =~ /^[123]$/
      puts "Enter 1 to start a new game, 2 to load saved game state or 3 to exit:"
      choice = gets.chomp
    end
    return choice
  end
  
  def continue_guessing
    draw_gallows(@limit)
    draw_board
    puts "Incorrectly guessed letters: #{@incorrect_guesses.join(", ")}"
    guess = get_input
    guess = get_input while duplicate?(guess)
    check_guess(guess)
    return true if @password.join == @guessing_board.join
  end
  
  def load_game
    puts "Loading..."
    if File.exist?(@save_directory)
      saved_state = File.open(@save_directory, "r")
      game = saved_state.read
      YAML::load(game).game_start
    else
      puts "No saved state found. Starting new game."
      self.game_start
    end
  end
  
  def choose_password
    puts "Loading dictionary..."
    dictionary = File.open(@dictionary_path, 'r')
    valid_passwords = dictionary.select { |x| x.length > 5 && x.length < 12 && x[0] !~ /[A-Z]/ }
    return valid_passwords.sample.chomp
  end
  
  def get_input
    puts "\nGuess the letter to continue or enter 'save' to save & exit:"
    guess = gets.chomp.downcase
    save_game if guess == 'save'
    until guess =~ /^[a-z]$/
      puts "Enter a single letter."
      guess = gets.chomp.downcase
    end
    return guess
  end
  
  def check_guess (guess)
    if @password.include?(guess)
      @password.each_with_index { |elem, index| @guessing_board[index] = guess if elem == guess }
    else
      @incorrect_guesses.push(guess)
      @limit -= 1
    end
  end
  
  def draw_title
    puts "--==*=*=*==--".center(50, " ")
    puts "-=*=- Hangman -=*=-".center(50, " ")
    puts "--==*=*=*==--".center(50, " ")
  end
  
  def draw_board
    draw_hr(@password.length)
    puts @guessing_board.join(" ")
    draw_hr(@password.length)
  end
  
  def draw_hr (length)
    puts "".center(length * 2, "=")
  end
  
  def duplicate? (guess)
    result = false
    if @guessing_board.include?(guess) || @incorrect_guesses.include?(guess)
      puts "You've already checked this letter!"
      return true 
    end
  end
  
  def save_game
    File.open(@save_directory, "w") do |file|
      save_state = YAML::dump(self)
      file.write(save_state)
      abort "Game saved. See you soon..."
    end
  end
  
  def draw_gallows (limit)
    send("gallows_#{limit}") # dynamically call a method from Gallows module
  end
end
game = Hangman.new