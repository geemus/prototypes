# TODO: add tags, so you can tag tests and only run a subset
# TODO: restart (reload files in question and restart test run? and/or rerun given test)
# TODO: Get interactive actually working

class Backtrace

  def initialize(&block)
    @max = 20
    start
  end

  def context(line_number)
    line = @buffer[line_number]
    
    lines = []
    File.open(line[:file], 'r') do |file|
      data = file.readlines
      min_line = [0, line[:line] - (@max / 2)].max
      max_line  = [line[:line] + (@max / 2), data.length].min

      lines << []
      min_line.upto(line[:line] - 1) do |line_number|
        lines[0] << "#{line_number}  #{data[line_number]}"
      end

      lines << "#{line[:line]}  #{data[line[:line]]}"

      lines << []
      (line[:line] + 1).upto(max_line) do |line_number|
        lines[2] << "#{line_number}  #{data[line_number]}"
      end
    end
    lines
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

    def initialize(header, &block)
      @afters     = []
      @backtrace  = Backtrace.new
      @befores    = []
      @description_stack = []
      @indent     = 1
      @success    = true
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

    def description
      @description_stack.compact.join(' ')
    end

    def green_line(content)
      print_line(content, "\e[32m")
    end

    def print_backtrace_context(line)
      @indent += 1
      print_line("#{@backtrace.lines[line]}: ")
      @indent += 1
      print("\n")
      before, during, after = backtrace.context(line)
      for line in before
        print_line("#{line.rstrip}")
      end
      yellow_line("#{during.rstrip}")
      for line in after
        print_line("#{line.rstrip}")
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
        @irb.context.workspace.instance_variable_set('@binding', block.binding)
        @irb.eval_input rescue SystemExit
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
      red_line("- #{description}")
      prompt(&block)
    end

    def red_line(content)
      print_line(content, "\e[31m")
    end

    def tests(description, &block)
      print_line(description || 'Trest.tests')
      @befores.push([])
      @afters.push([])
      @indent += 1
      if block_given?
        instance_eval(&block)
      end
      @indent -= 1
      @afters.pop
      @befores.pop
      @description_stack.pop
    end

    def test(description = nil, &block)
      @description_stack.push(description)
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
        red_line("- #{description}")
        if STDOUT.tty?
          prompt(&block)
        end
      when nil
        yellow_line("* #{description}")
      when true
        green_line("+ #{description}")
      end
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
  tests('true') {
    test('should be true')      { true == true }
  }
  test('false with backtrace') { xyzzy = 'foo'; @qux = foo; false }
  test('should be pending')
  tests('before') {
    before { @foo = 'bar' }
    after { @foo = 'baz' }
    test('should setup test') { @foo == 'bar' }
  }
  test('after should cleanup test') { @foo == 'baz' }
}

Trest.tests('seperate Trest.test') {
  test('instance variables from other Trest.test should be out of scope') { @foo.nil? }
}
