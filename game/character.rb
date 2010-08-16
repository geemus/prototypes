class Model

  def self.attributes
    @attributes ||=
      if superclass.respond_to?(:attributes)
        superclass.attributes
      else
        []
      end
  end

  def self.defaults
    @defaults ||= 
      if superclass.respond_to?(:defaults)
        superclass.defaults 
      else
        {}
      end
  end

  def self.attribute(name, options={})
    class_eval <<-EOS, __FILE__, __LINE__
      attr_accessor :#{name}
      private :#{name}=
    EOS
    attributes |= [name]
    defaults[name] = options[:default]
  end

  def initialize(attributes={})
    update(self.class.defaults.merge(attributes))
  end

  def update(attributes={})
    for key, value in attributes
      send("#{key}=", value)
    end
  end

end

class Character < Model

  attribute :brawns,      :default => 2
  attribute :brains,      :default => 1
  attribute :experience,  :default => 0
  attribute :health,      :default => 100
  attribute :level,       :default => 1

end

class Warrior < Character; end

pc = Warrior.new(:brawns => 3)
p pc

