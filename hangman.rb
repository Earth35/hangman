require 'yaml'

class Hangman
  def initialize
    @dictionary_path = "5desk.txt"
    @limit = 10
    @save_direcory = "save_state.yaml"
    main_menu
  end
  
  private

  def main_menu
    puts "--==*=*=*==--".center(50, " ")
    puts "-=*=- Hangman -=*=-".center(50, " ")
    puts "--==*=*=*==--".center(50, " ")
    puts "\n1 New Game"
    puts "2 Load Game"
    choice = get_mode
    if choice == "1"
      new_game
    else
      load_game
    end
  end
  
  def get_mode
    choice = gets.chomp
    until choice =~ /^[12]$/
      puts "Enter 1 to start a new game, enter 2 to load saved game state:"
      choice = gets.chomp
    end
    return choice
  end
  
  def new_game
    dictionary = File.open(@dictionary_path, 'r')
    password = choose_password(dictionary).split(//)  # array of correct
    guessing_board = password.map { "_" } # current board and correct guesses
    incorrect_guesses = []  # to prevent duplicates
    while @limit > 0
      status = continue(password, guessing_board, incorrect_guesses)
      if status
        puts "Congratulations, you win!"
        break
      else
        puts "Incorrect guesses left: #{@limit}"
      end
    end
    if @limit == 0
      puts "You lose!"
      puts "The correct word was: #{password.join}"
    end
  end
  
  def continue (password, guessing_board, incorrect_guesses)
    guess = get_guess
    while duplicate?(guess, guessing_board, incorrect_guesses)
      puts "You've already picked this letter. Pick another one:"
      guess = get_guess
    end
    check_guess(password, guess, guessing_board, incorrect_guesses)
    draw_hr(password.length)
    puts guessing_board.join(" ")
    draw_hr(password.length)
    if password.join == guessing_board.join
      return true
    else
      puts "Incorrectly guessed letters: #{incorrect_guesses.join(", ")}"
    end
  end
  
  def load_game
    puts "Loading..."
  end
  
  def choose_password (dict)
    puts "Loading dictionary..."
    valid_passwords = dict.select do |x|
      x.length > 5 && x.length < 12 && x[0] !~ /[A-Z]/
    end
    return valid_passwords.sample.chomp
  end
  
  def get_guess
    puts "\nGuess the letter:"
    guess = gets.chomp.downcase
    until guess =~ /^[a-z]$/
      puts "Invalid input. Enter a single letter."
      guess = gets.chomp.downcase
    end
    return guess
  end
  
  def check_guess (password, guess, correct, incorrect)
    if password.include?(guess)
      puts "Guess: #{guess}"
      password.each_with_index do |elem, index|
        correct[index] = guess if elem == guess
      end
    else
      incorrect.push(guess)
      @limit -= 1
    end
  end
  
  def draw_hr (length)
    puts "".center(length * 2, "=")
  end
  
  def duplicate? (guess, correct, incorrect)
    result = false
    return true if correct.include?(guess) || incorrect.include?(guess)
  end
end
game = Hangman.new