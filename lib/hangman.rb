class Game
  attr_reader :dictionary, :player, :incorrect_guesses_left, :original_word
  def initialize(dictionary, player)
    @dictionary = dictionary
    @player = player
    @incorrect_guesses_left = 6
    @original_word = dictionary.word.split("")
  end

  def start_game
    word = Array.new(original_word.length, "")
    p word, original_word
    # until
    print player.prompt_enter_guess
    player_letter = player.get_player_input
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
