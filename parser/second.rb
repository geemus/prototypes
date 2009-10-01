@stack = []

def descend(name, regex, string)
  if match = /^#{regex}/.match(string)
    @stack << [name, match.captures.first]
    parse(match.post_match) if match.post_match
  else
    nil
  end
end

def parse(string)
  sum(string)
end

def value(string = nil)
  if string
    descend('value', value, string)
  else
    /(\d+)/
  end
end

def sum(string)
  value(string)
end

parse('56 + 37')
p @stack

# value = parse('([0-9]+)') || parse("( #{expr} )")
# product = parse("#{value}( ([\*\/]) #{value})*")
# sum = parse("#{product}( ([\+\-]) #{product})*")
# expr = parse(sum)

# Value ← [0-9]+ / '(' Expr ')'
# Product ← Value (('*' / '/') Value)*
# Sum ← Product (('+' / '-') Product)*
# Expr ← Sum