module Minish

  def self.html(&block)
    Minish::HTML.new(&block)
  end

  class HTML

    def initialize(&block)
      @dom_stack = [[]]
      if block_given?
        html({}, &block)
      end
    end

    def method_missing(name, properties = {}, &block)
      element = [name.to_s, properties]
      @dom_stack[-1].push(element)
      @dom_stack.push(element)
      if block_given?
        val = instance_eval(&block)
        if val.is_a?(String)
          @dom_stack[-1].push(val)
        end
      end
      @dom_stack.pop
    end

    def to_html(element=@dom_stack[0][0])
      name, attributes, children = element[0], element[1], element[2..-1]
      html = ''
      html << "<#{name}"
      for key, value in attributes
        html << " #{key}=#{value.inspect}"
      end
      if children
        html << '>'
        for child in children
          if child.is_a?(String)
            html << child
          elsif child.is_a?(Array)
            html << to_html(child)
          end
        end
        html << "</#{name}>"
      else
        html << '/>'
      end
      html
    end

  end

end

def link_to(href, title, properties = {})
  a(properties.merge!(:href => href)) { title }
end

p html = Minish.html {
  body {
    div {
      ul(:class => 'foo') {
        li { '1' }
        li(:class => 'bar') { '2' }
        li(:class => 'baz') { '3' }
      }
    }
    span { link_to('http://0.0.0.0:4000', 'test') }
  }
}

p html.to_html