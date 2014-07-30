class Code
  COLORS = ['R','B','G','Y','P','O']
  NUM_PEGS = 5

  def initialize(answer_code="RBGY")
    @answer_code = answer_code
  end

  def self.colors
    COLORS
  end

  def self.num_pegs
    NUM_PEGS
  end

  def self.random
    colors = COLORS.sample(3) + COLORS.sample(2)
    # for i in 0..3
    #   colors << ['R','B','G','Y'].sample
    # end
    Code.new(colors.join(''))
  end

  def self.sanitize(code)
    if code.scan(/[rgbypoRGBYPO]+/).join('').length == NUM_PEGS
      return code.scan(/[rgbypoRGBYPO]+/).join('').upcase
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

  def display_matches(guess)
    exact_matches = @answer.exact_matches(guess)
    near_matches = @answer.near_matches(guess)

    [exact_matches, near_matches]
  end

  def win?(guess)
    @answer.exact_matches(guess) == Code.num_pegs
  end
end