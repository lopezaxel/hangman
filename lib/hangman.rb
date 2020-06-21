require "pry"

class Game
  attr_reader :dictionary, :player, :dict_word, :guesses_limit
  attr_accessor :loss
  def initialize(dictionary, player)
    @dictionary = dictionary
    @player = player
    @dict_word = dictionary.word.split("")
    @guesses_limit = 12
    @loss = false
  end

  def start_game
    word_guess = copy_word_empty
    guesses_left = guesses_limit

    until loss
      print player.prompt_enter_guess
      player_letter = player.get_player_input

      get_letter_matches(word_guess, player_letter)
      guesses_left -= 1 unless dict_word.include?(player_letter)

      give_feedback(word_guess, guesses_left)
    end
  end

  def get_letter_matches(guess_word, player_letter)
    dict_word.each_with_index do |letter, index|
      if player_letter == letter
        add_correct_letter(guess_word, player_letter, index)
        remove_letter_dict(index)
      end
    end
  end

  def add_correct_letter(guess_word, letter, index)
    guess_word[index] = letter
  end

  def remove_letter_dict(index)
    dict_word[index] = ""
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

  def get_player_input
    gets.chomp.downcase
  end

  def prompt_enter_guess
    "Enter your guess of a letter: "
  end
end

dict = Dictionary.new
player = Player.new
game = Game.new(dict, player)
game.start_game
