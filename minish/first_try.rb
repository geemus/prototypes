module Minish

  class CSS

    attr_accessor 

    def method_missing(name, properties = {}, &block)
      if properties.is_a?(Element)
        child = properties
        @pointer = Element.new(:name => name)
        @pointer.children << child
      else
        parent = @pointer
        @pointer = Element.new(:name => name, :properties => properties)
        if block_given?
          val = instance_eval(&block)
          @pointer.children << val if val.is_a?(String)
        end
        if parent
          parent.children << @pointer
          @pointer = parent
        end
      end
      @pointer
    end

    class Element

      attr_accessor :children, :name, :properties

      def initialize(attributes = {})
        attributes = {
          :children => []
        }.merge!(attributes)
        for key, value in attributes
          send(:"#{key}=", value)
        end
        self
      end

      def to_s
        properties = @properties && @properties.dup || {}
        klass = properties.delete(:class) || properties.delete('class')
        id = properties.delete(:id) || properties.delete('id')
        properties_map = properties.map{|key,value| "#{key}:#{value};"}.join(' ') unless properties.nil? || properties.empty?
        string = ''
        selector = "#{name}#{".#{klass}" if klass}#{"##{id}" if id}"
        if properties_map
          string << "#{selector}{#{properties_map}}"
        end
        unless @children.empty?
          string << unpack_children(self.name.to_s, self)
        end
        string
      end

      def unpack_children(scope, element)
        if element.children.empty?
          "#{scope} #{element}"
        else
          string = ''
          unless scope == element.name.to_s
            scope = "#{scope} #{element.name}"
            properties = @properties && @properties.dup || {}
            klass = properties.delete(:class) || properties.delete('class')
            id = properties.delete(:id) || properties.delete('id')
            properties_map = properties.map{|key,value| "#{key}:#{value};"}.join(' ') unless properties.nil? || properties.empty?
            string = ''
            selector = "#{scope} #{name}#{".#{klass}" if klass}#{"##{id}" if id}"
            if properties_map
              string << "#{selector}{#{properties_map}}"
            end
          end
          string << element.children.map {|child| unpack_children(scope, child)}.join
        end
      end

    end

  end

  def self.css(&block)
    Minish::CSS.new.instance_eval(&block)
  end

  class HTML

    attr_accessor :pointer

    def method_missing(name, properties = {}, &block)
      if properties.is_a?(Element)
        child = properties
        @pointer = Element.new(:name => name)
        @pointer.children << child
      else
        parent = @pointer
        @pointer = Element.new(:name => name, :properties => properties)
        if block_given?
          val = instance_eval(&block)
          @pointer.children << val if val.is_a?(String)
        end
        if parent
          parent.children << @pointer
          @pointer = parent
        end
      end
      @pointer
    end

    class Element

      attr_accessor :children, :name, :properties

      def initialize(attributes = {})
        attributes = {
          :children => []
        }.merge!(attributes)
        for key, value in attributes
          send(:"#{key}=", value)
        end
        self
      end

      def to_s
        properties_map = @properties.map{|key,value| "#{key}=#{value.inspect}"}.join unless @properties.nil? || @properties.empty?
        string = "<#{@name}#{' ' + properties_map if properties_map}"
        string << if @children.size > 0
          ">#{@children.join}</#{@name}>"
        else
          " />"
        end
      end

    end

  end

  def self.html(&block)
    Minish::HTML.new.instance_eval(&block)
  end

end

p Minish.html {
  body {
    div {
      ul(:class => 'foo') {
        li {}
        li(:class => 'bar') {}
        li(:class => 'baz') {}
      }
    }
    span { 'test' }
  }
}.to_s

p Minish.css {
  div(:color => '#333') {
    span(:color => '#000')
  }
  div {
    ul(:class => 'foo', :margin => 0, 'first-child' => { 'background-color' => '#999' }) {
      li(:color => '#999') { a('text-decoration' => 'none') }
      li(:id => 'bar', 'background-color' => '#000')
      li(:id => 'baz', 'background-color' => '#FFF')
    }
  }
}.to_s
