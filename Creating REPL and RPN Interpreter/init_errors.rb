# Class that defines functions to call errors with codes.
class InitErrors
  def call_error(code, var, line_counter, quit)
    if code == 1
      puts "Line #{line_counter}: Variable #{var} is not initialized"
    elsif code == 2
      puts "Line #{line_counter}: Operator #{var} applied to empty stack"
    elsif code == 3
      puts "Line #{line_counter}: #{var} elements in stack after evaluation"
    elsif code == 4
      puts "Line #{line_counter}: Unknown keyword #{var}"
    end
    exit(code) if quit
  end

  def exit_five(line_counter, quit)
    if line_counter == -1
      puts 'File cannot be found and/or read!'
    else
      puts "Line #{line_counter}: Could not evaluate expression!"
    end
    exit(5) if quit
  end

  def clean_exit(code, quit)
    exit(code) if code.zero? && quit
  end
end
