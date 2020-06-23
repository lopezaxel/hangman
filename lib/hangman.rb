require "pry"
require "json"

module Serializer
  @@filename = "saved_game.json"

  def to_json(word_guess, guesses_left)
    file = File.open(@@filename, "w")
    data = JSON.dump({
      :word_guess => word_guess,
      :guesses_left => guesses_left,
      :dict_word => @dict_word
      })
    file.write(data)
    file.close
  end

  def from_json
    file = File.open(@@filename, "r")
    contents = file.read
    file.close
    JSON.load(contents)
  end
end

class Game
  include Serializer

  attr_reader :dictionary, :player, :dict_word, :guesses_limit
  attr_accessor :loss
  def initialize(dictionary, player)
    @dictionary = dictionary
    @player = player
    @dict_word = dictionary.word.split("")
    @guesses_limit = 12
  end

  def start_game
    word_guess = new_array(dict_word)
    guesses_left = guesses_limit
    loss = false
    win = false

    if player.load_game == "load"
      saved_data = from_json

      @dict_word = saved_data["dict_word"]
      word_guess = saved_data["word_guess"]
      guesses_left = saved_data["guesses_left"]

      give_feedback(word_guess, guesses_left)
    end

    until loss || win
      puts player.ask_save_game
      print player.ask_guess
      player_input = player.input

      if letter_correct(player_input, dict_word, word_guess) && player_input.length == 1
        check_letter_match(word_guess, player_input)
      elsif player_input == "save"
        to_json(word_guess, guesses_left)
      else
        guesses_left = decrease_guesses_left(guesses_left)
      end

      give_feedback(word_guess, guesses_left)

      loss = true if check_loss(guesses_left)
      win = true if check_win(word_guess)
    end

    puts loss_message(dict_word) if loss
  end

  def load_saved_game
    saved_data = from_json
    p saved_data
    @dict_word = saved_data["dict_word"]
    word_guess = saved_data["word_guess"]
    guesses_left = saved_data["guesses_left"]
  end

  def letter_correct(letter, word, word2)
    word.include?(letter) && !word2.include?(letter)
  end

  def loss_message(word)
    "The word to guess was #{word.join}"
  end

  def check_loss(guesses_left)
    guesses_left.zero?
  end

  def check_win(guess)
    guess.none? { |letter| letter == "_" }
  end

  def decrease_guesses_left(guesses_left)
    guesses_left - 1
  end

  def check_letter_match(guess_word, player_letter)
    dict_word.each_with_index do |letter, index|
      next unless player_letter == letter && guess_word[index] == "_"

      add_letter(guess_word, player_letter, index)
    end
  end

  def add_letter(guess_word, letter, index)
    guess_word[index] = letter
  end

  def new_array(model_word)
    Array.new(model_word.length, "_")
  end

  def give_feedback(word, guesses_left)
    puts "Correct guesses #{word.join(" ")}"
    puts "Incorrect guesses left #{guesses_left}\n"
  end
end

class Dictionary
  attr_reader :dictionary, :word

  @@dict_name = "dictionary.txt"
  def initialize
    @dictionary = load_dictionary(@@dict_name)
    @word = select_random_word
  end

  def load_dictionary(filename)
    File.open(filename, "r").readlines
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
  def initialize; end

  def input
    gets.chomp.downcase
  end

  def ask_guess
    "Enter your guess of a letter: "
  end

  def ask_save_game
    "\nType 'save' to save the game"
  end

  def load_game
    print "Type 'yes' to load the last saved game: "
    gets.chomp.downcase
  end
end

dict = Dictionary.new
player = Player.new
game = Game.new(dict, player)
game.start_game
