# number = /(\d+)/
# factor = number || /\(#{expression}\)/
# component = factor && /(\*|\/)/ && factor
# expression = component && /(\+|\-)/ && component 

# Value ← [0-9]+ / '(' Expr ')'
# Product ← Value (('*' / '/') Value)*
# Sum ← Product (('+' / '-') Product)*
# Expr ← Sum

def value(str)
  return nil unless str
  match('value', /(\d+)/, str) || match('value', expr(_expr(str)), str)
end

  def _expr(str)
    if match = /^ \((.*)\)/.match(str)
      match.captures.first
    else
      nil
    end
  end

def product(str)
  return nil unless str
  value(str) || match('product', value(_value(str)), str)
end

  def _value(str)
    if match = /^ ([\*\/]) (.*)/.match(str)
      @operator = match.captures[0]
      match.captures[1]
    else
      nil
    end
  end

def sum(str)
  return nil unless str
  product(str) || match('sum', product(_product(str)), str)
end

  def _product(str)
    if match = /^ ([\+\-]) (.*)/.match(str)
      @operator = match.captures[0]
      match.captures[1]
    else
      nil
    end
  end

def expr(str)
  return nil unless str
  sum(str)
end

def match(name, regex, string)
  # p "#{name} #{regex.inspect} '#{string}'"
  return nil if regex.nil?
  if match = /^#{regex}/.match(string)
    @value = match.captures.first
    regex
  else
    nil
  end
end

def parse(string)
  until string.empty?
    regex = expr(string)
    p @operator if @operator
    p @value
    break if regex.nil?
    match = regex.match(string)
    string = match.post_match
  end
end

parse('5 + 7')