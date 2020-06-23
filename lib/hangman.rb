require "pry"
require "json"

module Serializer
  def to_json(file, word_guess, guesses_left)
    file = File.open(file, "w")
    data = JSON.dump({
      :word_guess => word_guess,
      :guesses_left => guesses_left,
      :dict_word => @dict_word
      })
    file.write(data)
    file.close
  end

  def from_json(file)
    file = File.open(@@filename, "r")
    contents = file.read
    file.close
    JSON.load(contents)
  end
end

class Game
  include Serializer

  attr_reader :player
  attr_accessor :dict_word, :word_guess, :guesses_left
  def initialize(dictionary, player)
    @player = player
    @dict_word = dictionary.word.split("")
    @guesses_left = 12
    @word_guess = new_array(dict_word)
  end

  def start_game
    loss = false
    win = false

    load_saved_game if player.ask_load_game == "load"

    until loss || win
      puts player.ask_save_game
      print player.ask_guess
      player_input = player.input

      if letter_correct(player_input, dict_word, word_guess) && player_input.size == 1
        check_letter_match(word_guess, player_input)
      elsif player_input == "save"
        save_game
      else
        subtract_guesses
      end

      give_feedback(word_guess, guesses_left)

      loss = true if check_loss(guesses_left)
      win = true if check_win(word_guess)
    end

    puts loss_message(dict_word) if loss
  end

  def save_game
    num = 1
    folder = create_folder("games")
    file = create_file(folder, num)
    file = create_file(folder, num += 1) while File.exists?(file)
    to_json(file, word_guess, guesses_left)
  end

  def create_folder(foldername)
    Dir.mkdir(foldername) unless File.exists?(foldername)
    foldername
  end

  def create_file(foldername, num = 1)
    "#{foldername}/game_#{num}.json"
  end

  def load_saved_game
    p Dir.glob("games/*")

    saved_data = from_json()

    self.dict_word = saved_data["dict_word"]
    self.word_guess = saved_data["word_guess"]
    self.guesses_left = saved_data["guesses_left"]

    give_feedback(word_guess, guesses_left)
  end

  def subtract_guesses
    self.guesses_left -= 1
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
    puts "\nCorrect guesses #{word.join(" ")}"
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

  def ask_load_game
    print "Type 'load' to load the last saved game: "
    gets.chomp.downcase
  end
end

dict = Dictionary.new
player = Player.new
game = Game.new(dict, player)
game.start_game
