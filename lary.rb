class Lary < Array

  Array.public_instance_methods(false).each do |method|
    class_eval <<-RUBY
      def #{method}(*args)
        lary
        super
      end
    RUBY
  end

  def initialize(&block)
    if block_given?
      @block = block
    else
      @block = lambda {|lary| lary}
    end
    @loaded = false
  end

  private

  def lary
    unless @loaded
      @loaded = true
      self.replace(@block.call(self))
    end
  end

end

p Lary.new { [1,2] }
