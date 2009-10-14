module Minish

  def self.css(&block)
    Minish::CSS.new(&block)
  end

  class CSS

    attr_accessor :styles

    def initialize(&block)
      @selector_stack = []
      @styles = {}
      if block_given?
        instance_eval(&block)
      end
    end

    def _(name, value = nil, &block)
      @selector_stack.push(name.to_s)
      (@styles[@selector_stack.join(' ')] ||= {}).merge!(value)
      if block_given?
        instance_eval(&block)
      end
      @selector_stack.pop
    end

    def to_css
      css = ''
      for selector in @styles.keys.sort
        css << "#{selector}{"
        for key, value in @styles[selector]
          css << "#{key}:#{value};"
        end
        css << "}"
      end
      css
    end

  end

end

background = '#EEE'
foreground = '#666'
default_colors = { 'background-color' => background, 'color' => foreground }

def zebra
  _('li.even', 'background-color' => '#EEE')
  _('li.odd', 'background-color' => '#FFF')
end

p css = Minish.css {
  _('ul', default_colors.merge!('font-size' => '1.5em')) {
      _('li', 'background-color' => '#EEE')
      
      _('li.foo', 'color' => '#666') {
        _('span',
          'background-color' => '#000',
          'color' => '#CCC'
        )
      }
      
      _('li#bar', 'background-color' => foreground, 'color' => background)
      zebra
  }
}

p css.to_css

# ul {
#   < li { 
#     background-color: #FFF
#     <:first-child {
#       background-color: #666
#     }    
#   }
#   < li.foo {
#     color: #666
#     < span {
#       color: #CCC
#     }
#   }
#   < li#bar {
#     color: #CCC
#   }
# }