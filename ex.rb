class Numbers
  attr_accessor :number1

  def initialize
    @number1 = 15
  end

  def subtract
    number1 -= 1
    p number1
  end
end

num = Numbers.new
num.subtract
