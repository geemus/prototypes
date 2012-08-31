require 'active_model'

class Valid
  include ActiveModel::Validations

  attr_accessor :name

  validates_presence_of :name
end
# validates_acceptance_of, validates_confirmation_of, validates_exclusion_of, validates_format_of, validates_inclusion_of, validates_length_of, validates_numericality_of, validates_presence_of, validates_size_of

valid = Valid.new
p valid.valid?
valid.name = 'foo'
p valid.valid?

require 'heroku-api'

heroku = Heroku::API.new(:api_key => 'REDACTED', :mock => true)

require 'redcarpet'

markdown = Redcarpet::Markdown.new(
  Redcarpet::Render::XHTML,
  :autolink => true,
  :space_after_headers => true
)

puts markdown.render('*hello* world')

require 'sinatra/base'

class MyApp < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end

