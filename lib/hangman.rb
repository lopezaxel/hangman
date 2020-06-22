require "pry"

class Game
  attr_reader :dictionary, :player, :dict_word, :guesses_limit
  attr_accessor :loss
  def initialize(dictionary, player)
    @dictionary = dictionary
    @player = player
    @dict_word = dictionary.word.split("")
    @guesses_limit = 12
  end

  def start_game
    word_guess = copy_word_empty
    guesses_left = guesses_limit
    loss = false
    win = false

    until loss || win
      player_letter = player.get_letter

      if dict_word.include?(player_letter) && !word_guess.include?(player_letter)
        get_letter_matches(word_guess, player_letter)
      else
        guesses_left = decrease_guesses_left(guesses_left)
      end

      give_feedback(word_guess, guesses_left)

      loss = true if check_loss(guesses_left)
      win = true if check_win(word_guess)
    end

    if loss
      puts "The word to guess was #{dict_word}"
    end
  end

  def check_loss(guesses_left)
    guesses_left == 0
  end

  def check_win(guess)
    guess.none? { |letter| letter == "_" }
  end

  def decrease_guesses_left(guesses_left)
    guesses_left - 1
  end

  def get_letter_matches(guess_word, player_letter)
    dict_word.each_with_index do |letter, index|
      if player_letter == letter && guess_word[index] == "_"
        add_correct_letter(guess_word, player_letter, index)
      end
    end
  end

  def add_correct_letter(guess_word, letter, index)
    guess_word[index] = letter
  end

  def copy_word_empty
    Array.new(dict_word.length, "_")
  end

  def give_feedback(word, guesses_left)
    puts "Correct guesses #{join_word(word)}"
    puts "Incorrect guesses left #{guesses_left}\n"
  end

  def join_word(word)
    word.join(" ")
  end
end

class Dictionary
  attr_reader :dictionary, :word
  def initialize
    @dictionary = load_dictionary
    @word = select_random_word
  end

  def load_dictionary
    File.open("dictionary.txt", "r").readlines
  end

  def select_random_word
    word = random_word
    word = random_word until word.length >= 5 && word.length <= 12
    word
  end

  def random_word
    dictionary.sample.strip.downcase
  end
end

class Player
  def initialize

  end

  def get_input
    gets.chomp.downcase
  end

  def prompt_enter_guess
    "Enter your guess of a letter: "
  end

  def get_letter
    print prompt_enter_guess
    get_input
  end
end

dict = Dictionary.new
player = Player.new
game = Game.new(dict, player)
game.start_game
