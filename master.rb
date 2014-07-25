class Code
  COLOR_DICT = {
    0 => 'R',
    1 => 'B',
    2 => 'G',
    3 => 'Y',
    4 => 'P',
    5 => 'O'
  }

  def initialize(answer_code="RBGY")
    @answer_code = answer_code
  end

  def self.random
    colors = []
    4.times do
      colors << ['R','B','G','Y','P','O'].sample
    end
    # for i in 0..3
    #   colors << ['R','B','G','Y'].sample
    # end
    Code.new(colors.join(''))
  end

  def self.sanitize(code)
    if code.scan(/[012345rgbypoRGBYPO]+/).join('').length == 4
      return code.scan(/[012345rgbypoRGBY]+/).join('').upcase
    end
    false
  end

  def code
    @answer_code
  end

  def count_colors(code)
    count_colors = Hash.new(0)

    code.split('').each do |col|
      count_colors[col] += 1
    end

    count_colors
  end

  def exact_matches(code)
    total = 0
    for i in 0..code.length-1
      if @answer_code[i] == code[i]
        total += 1
      end
    end
    total
  end

  def near_matches(code)
    total = 0

    answer_colors = count_colors(@answer_code)
    player_colors = count_colors(code)

    player_colors.each do |col, val|
      # total += [answer_colors[col], val].min
      if answer_colors[col] > val
        total += val
      else
        total += answer_colors[col]
      end
    end

    total - exact_matches(code)
  end
end

class Game
  attr_reader :answer

  MAX_TURNS = 5

  def initialize(answer = Code.random)
    if answer.class == Code
      @answer = answer
    else
      @answer = Code.new(answer)
    end
  end

  def play
    MAX_TURNS.times do
      new_guess = get_guess
      display_matches(new_guess)
      if win?(new_guess)
        puts "You win!"
        return
      end
    end

    puts "You lose, the answer was #{@answer.code}!"
  end

  def get_guess
    puts "What's your guess?"
    gets.chomp
  end

  def display_matches(guess)
    exact_matches = @answer.exact_matches(guess)
    near_matches = @answer.near_matches(guess)

    [exact_matches, near_matches]
  end

  def win?(guess)
    @answer.exact_matches(guess) == 4
  end
end