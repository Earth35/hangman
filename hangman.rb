require 'yaml'

class Hangman
  def initialize
    @dictionary_path = "5desk.txt"
    @limit = 10
    @save_directory = "save_state.yaml"
    @password = choose_password.split(//)  # array of correct letters
    @guessing_board = @password.map { "_" } # current board and correct guesses    
    @incorrect_guesses = []  # prevent duplicates
    main_menu
  end
  
  protected
  
  def new_game
    while @limit > 0
      status = continue
      if status
        puts "Congratulations, you win!"
        draw_board
        break
      else
        puts "Incorrect guesses left: #{@limit}"
      end
    end
    if @limit == 0
      puts "You lose!"
      puts "The correct word was: #{@password.join}"
    end
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
      self.new_game
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
  
  def continue
    draw_board
    puts "Incorrectly guessed letters: #{@incorrect_guesses.join(", ")}"
    guess = get_input
    guess = get_input while duplicate?(guess)
    check_guess(guess)
    return true if @password.join == @guessing_board.join
  end
  
  def load_game
    puts "Loading..."
    saved_state = File.open("save_state.yaml", "r")
    game = saved_state.read
    YAML::load(game).new_game
  end
  
  def choose_password
    puts "Loading dictionary..."
    dictionary = File.open(@dictionary_path, 'r')
    valid_passwords = dictionary.select do |x|
      x.length > 5 && x.length < 12 && x[0] !~ /[A-Z]/
    end
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
      @password.each_with_index do |elem, index|
        @guessing_board[index] = guess if elem == guess
      end
    else
      @incorrect_guesses.push(guess)
      @limit -= 1
    end
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
    return true if @guessing_board.include?(guess) || @incorrect_guesses.include?(guess)
  end
  
  def save_game
    File.open(@save_directory, "w") do |file|
      save_state = YAML::dump(self)
      file.write(save_state)
      abort "Game saved. See you soon..."
    end
  end
end
game = Hangman.new