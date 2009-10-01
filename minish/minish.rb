require 'rubygems'
require 'treetop'
Treetop.load('minish')

parser = MinishParser.new
p parser.parse('div { span }')
p parser.parse('div.foo')
# p parser.parse('div#bar')