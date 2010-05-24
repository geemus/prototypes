# option/required arguments
# use inline, but normally include something that makes it all noops, by overridding this you get the goods
# include a bin file that can parse/output this stuff

module Lexical

  def self.included(other)
    other.class_eval do
      extend(Lexical::ClassMethods)
      include(Lexical::InstanceMethods)
    end
  end

  module ClassMethods

    def noun(name, details)
      lexical_nouns[name] = details
    end

    def nouns
      display_lexical(lexical_nouns)
    end

    def verb(name, details)
      lexical_verbs[name] = details
    end

    def verbs
      display_lexical(lexical_verbs)
    end

    private

    def display_lexical(data)
      for key, value in data
        arguments = if value[:arguments]
          "[light_black]#{value[:arguments].join('[/][bold],[/][light_black]')}[/]"
        end
        Formatador.display_line("[bold]#{key}(#{arguments})[/] #{value[:description]}")
      end
      nil
    end

    def lexical_nouns
      @lexical_nouns ||= {}
    end

    def lexical_verbs
      @lexical_verbs ||= {}
    end

  end

  module InstanceMethods

    def nouns
      self.class.nouns
    end

    def verbs
      self.class.verbs
    end

  end
end

