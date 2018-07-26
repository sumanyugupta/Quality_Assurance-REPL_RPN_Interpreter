# Class that checks the file argument provided by user.
class ArgsChecker
  attr_accessor :stack
  attr_reader :lin_c
  attr_accessor :map
  attr_reader :error_data

  def initialize
    @error_data = []
    @stack = []
    @lin_c = 0
    @map = {}
  end

  def check_args(arr)
    @lin_c = 0
    if arr.count < 1
      run_repl
    else
      value = check_array_arguments(arr)
      return value unless value.is_a?(Array)
      concat = read_file(arr)
      return [5, 0, -1] if concat == 'INV'
      vals = execute_rpn(concat)
      return vals
    end
  end

  def define_variable(input)
    if !input[1].nil? && input[1].length == 1 && input[1].match(/[a-zA-Z]/)
      @map = {} if @map.nil?
      call_error(5, 0) if input.length == 2
      val = do_math(input[2..input.length - 1])
      @map[input[1].upcase] = val[0] unless val.empty? || @stack.length > 1
      call_error(3, @stack.length) if @stack.length > 1
      puts @map[input[1].upcase] unless val.empty? || @stack.length > 1
      @stack.clear
    else
      call_error(5, nil)
    end
  end

  def check_first_element(input)
    return if input[0].nil?
    first_element = input[0].upcase.strip
    if %w[LET PRINT QUIT].include?(first_element)
      if first_element == 'LET'
        define_variable(input)
      elsif first_element == 'PRINT'
        do_math(input[1..input.length - 1])
      end
      true
    end
  end

  def call_error(cod, var)
    puts "Line #{@lin_c}: Variable #{var} is not initialized" if cod == 1
    puts "Line #{@lin_c}: Operator #{var} applied to empty stack" if cod == 2
    puts "Line #{@lin_c}: #{var} elements in stack after evaluation" if cod == 3
    puts "Line #{@lin_c}: Unknown keyword #{var}" if cod == 4
    puts "Line #{@lin_c}: Could not evaluate expression" if cod == 5
    @stack.clear
  end

  def handle_more(input, val)
    do_math(input) unless val
    call_error(3, @stack.length) if @stack.length > 1
    puts @stack[0] unless @stack.empty? || @stack[0].nil? || @stack.length > 1
  end

  def parse_line(input)
    return if input[0].nil?
    return 'QUIT' if input[0].casecmp('QUIT').zero?
    input.each do |element|
      a = element.length == 1 && element.match(/[A-Za-z]/)
      b = %w[+ - / * LET PRINT QUIT].include?(element.upcase)
      c = element.to_i.to_s == element
      call_error(4, element) unless a || b || c
      return 'INV' unless a || b || c
    end
  end

  def handle_input(input)
    @lin_c += 1
    @stack = []
    input = input.split(' ')
    value = parse_line(input)
    return value if value == 'QUIT'
    unless value == 'INV'
      val = check_first_element(input)
      handle_more(input, val)
    end
  end

  def do_math(input)
    input.each do |i|
      if %w[LET PRINT QUIT].include?(i.upcase)
        call_error(5, 0)
        return []
      elsif %w[+ - * /].include?(i)
        return [] unless handle_operators(i)
      elsif i.length == 1 && i.match(/[a-zA-Z]/)
        if @map.key?(i.upcase)
          @stack.push(@map[i.upcase])
        else
          call_error(1, i)
          return []
        end
      else
        @stack.push(i)
      end
    end
    @stack
  end

  def handle_operators(opt)
    operands = init_operands(opt)
    if operands.empty?
      false
    elsif operands[0].zero? && opt == '/'
      call_error(5, 0)
      false
    else
      @stack.push(operands[1].send(opt, operands[0]))
      true
    end
  end

  def init_operands(opt)
    if @stack.length < 2
      call_error(2, opt)
      []
    else
      a = @stack.pop.to_i
      b = @stack.pop.to_i
      [a, b]
    end
  end

  def run_repl
    @map = {} if @map.nil?
    @stack = [] if @stack.nil?
    repl = lambda { |prompt|
      print prompt
      exit(0) if handle_input(gets.chomp!) == 'QUIT'
    }
    loop do
      repl['> ']
    end
  end

  def init_values
    @map = {}
    @lin_c = 0
    @error_data = []
    all_files = curr = []
    vals = [all_files, curr]
    vals
  end

  def read_file(arr)
    vals = init_values
    arr.each do |file_name|
      return 'INV' unless File.file?(file_name)
      vals[1] = File.readlines(file_name)
      vals[1].each(&:chomp!)
      vals[0].push(vals[1])
    end
    vals[0]
  end

  def check_array_arguments(input)
    @error_data = []
    input.each do |file|
      return @error_data = [5, 0, -1] if (file[-3..-1] || file).strip != 'rpn'
    end
  end

  def parse_file_line(input)
    return if input[0].nil?
    @error_data = [0, 0, 0] if input[0].casecmp('QUIT').zero?
    return 'INV' if input[0].casecmp('QUIT').zero?
    input.each do |element|
      a = element.length == 1 && element.match(/[A-Za-z]/)
      b = %w[+ - / * LET PRINT QUIT].include?(element.upcase)
      c = element.to_i.to_s == element
      @error_data = [4, element, @lin_c] unless a || b || c
      return 'INV' unless a || b || c
    end
  end

  def execute_rpn(file)
    file.each do |line|
      line.each do |inner|
        @stack = []
        @lin_c += 1
        inner = inner.split(' ')
        return @error_data if parse_file_line(inner).eql? 'INV'
        check_first_file_element(inner)
        return @error_data unless @error_data.empty?
      end
    end; []
  end

  def branches(input)
    val = define_file_variable(input) if input[0].casecmp('LET').zero?
    return 'INV' if val == 'INV'
  end

  def check_first_file_element(first_el)
    return if first_el[0].nil?
    if first_el[0].upcase =~ /LET|PRINT|QUIT/
      return 'INV' if branches(first_el) == 'INV'
      if first_el[0].casecmp('PRINT').zero?
        return 'INV' if do_file_math(first_el[1..first_el.length - 1]) == []
        @error_data = [3, @stack.length, @lin_c] if @stack.length > 1
        return 'INV' if @stack.length > 1
        puts @stack[0]
      end
    else
      do_file_math(first_el)
      @error_data = [3, @stack.length, @lin_c] if @stack.length > 1
      return 'INV' if @stack.length > 1
    end
  end

  def define_file_variable(inp)
    c = !inp[1].nil? && inp[1].length == 1 && inp[1].match(/[a-zA-Z]/)
    @error_data = [5, 0, @lin_c] unless c && inp.length > 2
    return 'INV' unless c && inp[1].match(/[a-zA-Z]/) || c
    @map = {} if @map.nil?
    val = do_file_math(inp[2..inp.length - 1])
    @error_data = [3, @stack.length, @lin_c] if @stack.length > 1
    return 'INV' if @stack.length > 1
    @map[inp[1].upcase] = val[0] unless val.empty?
    return 'INV' if val.empty?
    @stack.clear
  end

  def do_more_math(input)
    if @map.key?(input.upcase)
      @stack.push(@map[input.upcase])
      true
    else
      @error_data = [1, input, @lin_c]
      false
    end
  end

  def do_file_math(input)
    input.each do |i|
      if %w[LET PRINT QUIT].include?(i.upcase)
        @error_data = [5, 0, @lin_c]
        return []
      elsif %w[+ - * /].include?(i)
        return [] unless handle_file_operators(i)
      elsif i.length == 1 && i.match(/[a-zA-Z]/)
        return [] unless do_more_math(i)
      else
        @stack.push(i)
      end
    end
    @stack
  end

  def handle_file_operators(opt)
    operands = init_file_operands(opt)
    if operands.empty?
      false
    elsif operands[0].zero? && opt == '/'
      @error_data = [5, 0, @lin_c]
      false
    else
      @stack.push(operands[1].send(opt, operands[0]))
      true
    end
  end

  def init_file_operands(opt)
    if @stack.length < 2
      @error_data = [2, opt, @lin_c]
      []
    else
      a = @stack.pop.to_i
      b = @stack.pop.to_i
      [a, b]
    end
  end
end
