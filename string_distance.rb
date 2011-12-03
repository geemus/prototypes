def levenshtein(first, last)
  distances = [] # 0x0s
  0.upto(first.length) do |index|
    distances << [index] + [0] * last.length
  end
  distances[0] = 0.upto(last.length).to_a
  1.upto(last.length) do |last_index|
    1.upto(first.length) do |first_index|
      first_char = first[first_index - 1, 1]
      last_char = last[last_index - 1, 1]
      if first_char == last_char
        distances[first_index][last_index] = distances[first_index - 1][last_index - 1] # noop
      else
        distances[first_index][last_index] = [
          distances[first_index - 1][last_index],     # deletion
          distances[first_index][last_index - 1],     # insertion
          distances[first_index - 1][last_index - 1]  # substitution
        ].min + 1 # cost
      end
    end
  end
  distances[first.length][last.length]
end

def damerau_levenshtein(first, last)
  distances = [] # 0x0s
  0.upto(first.length) do |index|
    distances << [index] + [0] * last.length
  end
  distances[0] = 0.upto(last.length).to_a
  1.upto(last.length) do |last_index|
    1.upto(first.length) do |first_index|
      first_char = first[first_index - 1, 1]
      last_char = last[last_index - 1, 1]
      if first_char == last_char
        distances[first_index][last_index] = distances[first_index - 1][last_index - 1] # noop
      else
        distances[first_index][last_index] = [
          distances[first_index - 1][last_index],     # deletion
          distances[first_index][last_index - 1],     # insertion
          distances[first_index - 1][last_index - 1]  # substitution
        ].min + 1 # cost
        if first_index > 1 && last_index > 1
          first_previous_char = first[first_index - 2, 1]
          last_previous_char = last[last_index - 2, 1]
          if first_char == last_previous_char && first_previous_char == last_char
            distances[first_index][last_index] = [
              distances[first_index][last_index],
              distances[first_index - 2][last_index - 2] + 1 # transposition
            ].min
          end
        end
      end
    end
  end
  distances[first.length][last.length]
end

def vs(first, last)
  p "#{first} <=> #{last} = { l => #{levenshtein(first, last)}, dl => #{damerau_levenshtein(first, last)} }"
end

vs("is", "is")            # => "is <=> is = { l => 0, dl => 0 }"
vs("kitten", "sitting")   # => "kitten <=> sitting = { l => 3, dl => 3 }"
vs("Saturday", "Sunday")  # => "Saturday <=> Sunday = { l => 3, dl => 3 }"
vs("is", "si")            # => "is <=> si = { l => 2, dl => 1 }"
