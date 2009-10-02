# TODO: restart (reload files in question and restart test run? and/or rerun given test)

class Backtrace

  attr_accessor :buffer, :max

  def initialize(&block)
    @max = 20
    start
  end

  def lines
    @buffer.map {|event| "#{event[:file]}:#{event[:line]} in #{event[:method]}"}
  end

  def start
    @buffer = []
    @size   = 0
    Kernel.set_trace_func(
      lambda { |event, file, line, id, binding, classname|
        if event == 'call'
          unshift({:file => file, :line => line, :method => id})
        end
      }
    )
  end

  def stop
    Kernel.set_trace_func(lambda {})
    @buffer.shift # remove the call to stop from the buffer
  end

  def unshift(line)
    @buffer.unshift(line)
    if @size == @max
      @buffer.pop
    else
      @size += 1
    end
  end

end

module Trest

  def self.tests(header = nil, &block)
    Trest::Tests.new(header, &block)
  end

  class Tests

    attr_accessor :backtrace

    def initialize(header, tags = [], &block)
      @afters     = []
      @backtrace  = Backtrace.new
      @befores    = []
      @description_stack = []
      @if_tagged     = ARGV.select {|tag| tag.match(/^[^\^]/)}
      @unless_tagged = ARGV.select {|tag| tag.match(/^\^/)}.map {|tag| tag[1..-1]}
      @indent     = 1
      @success    = true
      @tag_stack = []
      print("\n")
      tests(header, &block)
      print("\n")
      if @success
        exit(0)
      else
        exit(1)
      end
    end

    def after(&block)
      @afters[-1].push(block)
    end

    def before(&block)
      @befores[-1].push(block)
    end

    def full_description
      "#{@description_stack.compact.join(' ')} #{full_tags}"
    end

    def full_tags
      unless @tag_stack.flatten.empty?
        "[#{@tag_stack.flatten.join(', ')}]"
      end
    end

    def green_line(content)
      print_line(content, "\e[32m")
    end

    def print_backtrace_context(line)
      @indent += 1
      print_line("#{@backtrace.lines[line]}: ")
      @indent += 1
      print("\n")
      line = @backtrace.buffer[line]
      File.open(line[:file], 'r') do |file|
        data = file.readlines
        min_line = [0, line[:line] - (@backtrace.max / 2)].max
        max_line  = [line[:line] + (@backtrace.max / 2), data.length].min
        min_line.upto(line[:line] - 1) do |line_number|
          print_line("#{line_number}  #{data[line_number].rstrip}")
        end
        yellow_line("#{line[:line]}  #{data[line[:line]].rstrip}")
        (line[:line] + 1).upto(max_line) do |line_number|
          print_line("#{line_number}  #{data[line_number].rstrip}")
        end
      end
      @indent -= 2
      print("\n")
    end

    def print_backtrace
      @indent += 1
      if @backtrace.lines.empty?
        print_line('no backtrace available')
      else
        index = 1
        for line in @backtrace.lines
          print_line("#{index}  #{line}")
          index += 1
        end
      end
      @indent -= 1
      print("\n")
    end

    def print_line(content, color = nil)
      if color && STDOUT.tty?
        content = "#{color}#{content}\e[0m"
      end
      print("#{' ' * (@indent * 2)}#{content}\n")
    end

    def prompt(&block)
      print("#{' ' * (@indent * 2)}Action? [c,i,q,t,#,?]? ")
      choice = STDIN.gets.strip
      print("\n")
      case choice
      when 'c'
        return
      when 'i'
        print_line('Starting interactive session...')
        if @irb.nil?
          require 'irb'
          ARGV.clear # Avoid passing args to IRB
          IRB.setup(nil)
          @irb = IRB::Irb.new(nil)
          IRB.conf[:MAIN_CONTEXT] = @irb.context
          IRB.conf[:PROMPT][:TREST] = {}
        end
        for key, value in IRB.conf[:PROMPT][:SIMPLE]
          IRB.conf[:PROMPT][:TREST][key] = "#{' ' * (@indent * 2)}#{value}"
        end
        @irb.context.prompt_mode = :TREST
        @irb.context.workspace = IRB::WorkSpace.new(block.binding)
        begin
          @irb.eval_input
        rescue SystemExit
        end
      when 'q'
        exit(1)
      when 't'
        print_backtrace
      when '?'
        print_line('c - ignore this error and continue')
        print_line('i - interactive mode')
        print_line('q - quit Trest')
        print_line('t - display backtrace')
        print_line('# - enter a number of a backtrace line to see its context')
        print_line('? - display help')
      when /\d/
        index = choice.to_i - 1
        if backtrace.lines[index]
          print_backtrace_context(index)
        else
          red_line("#{choice} is not a valid backtrace line, please try again.")
        end
      else
        red_line("#{choice} is not a valid choice, please try again.")
      end
      red_line("- #{full_description}")
      prompt(&block)
    end

    def red_line(content)
      print_line(content, "\e[31m")
    end

    def tests(description, tags = [], &block)
      print_line(description || 'Trest.tests')
      @tag_stack.push([*tags])
      @befores.push([])
      @afters.push([])
      @indent += 1
      if block_given?
        instance_eval(&block)
      end
      @indent -= 1
      @afters.pop
      @befores.pop
      @tag_stack.pop
    end

    def test(description = nil, tags = [], &block)
      @description_stack.push(description)
      @tag_stack.push([*tags])
      if (@if_tagged.empty? || !(@if_tagged & @tag_stack.flatten).empty?) && (@unless_tagged.empty? || (@unless_tagged & @tag_stack.flatten).empty?)
        if block_given?
          for before in @befores.flatten.compact
            before.call
          end
          @backtrace.start
          success = instance_eval(&block)
          @success = @success && success
          @backtrace.stop
          for after in @afters.flatten.compact
            after.call
          end
        else
          success = nil
        end
        case success
        when false
          red_line("- #{full_description}")
          if STDOUT.tty?
            prompt(&block)
          end
        when nil
          yellow_line("* #{full_description}")
        when true
          green_line("+ #{full_description}")
        end
      else
        print_line("_ #{full_description}")
      end
      @tag_stack.pop
      @description_stack.pop
    end

    def yellow_line(content)
      print_line(content, "\e[33m")
    end

  end

end

def foo
  bar
end

def bar
  baz
end

def baz
  'qux'
end

Trest.tests {
  tests('true', 'true') {
    test('should be true')      { true == true }
  }
  test('false with backtrace', 'false') { xyzzy = 'foo'; @qux = foo; false }
  test('should be pending')
  tests('before') {
    before { @foo = 'bar' }
    after { @foo = 'baz' }
    test('should setup test', ['before', 'after']) { @foo == 'bar' }
  }
}

Trest.tests('seperate Trest.test') {
  test('instance variables from other Trest.test should be out of scope') { @foo.nil? }
}
