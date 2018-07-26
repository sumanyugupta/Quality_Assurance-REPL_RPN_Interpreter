require 'minitest/autorun'
require_relative 'init_errors'

class InitErrorsTest < Minitest::Test

  def setup
    @init = InitErrors.new
  end

  # Asserts that the program returns an exit code of one due to an error.
  def test_code_one
    code = 1
    var = '-'
    line = 3
    assert_output("Line 3: Variable - is not initialized\n") {@init.call_error(code, var, line, false)}
  end

  # Asserts that the program returns an exit code of two due to an error.
  def test_code_two
  	code = 2
  	var = '-'
  	line = 3
  	assert_output("Line 3: Operator - applied to empty stack\n") {@init.call_error(code, var, line, false)}
  end

  # Asserts that the program returns an exit code of three due to an error.
  def test_code_three
  	code = 3
  	var = 3
  	line = 3
  	assert_output("Line 3: 3 elements in stack after evaluation\n") {@init.call_error(code, var, line, false)}
  end

  # Asserts that the program returns an exit code of four due to an error.
  def test_code_four
    code = 4
    var = 'poop'
    line = 3
    assert_output("Line 3: Unknown keyword poop\n") {@init.call_error(code, var, line, false)}
  end

  # Asserts that the program returns an exit code of five due to an error.
  def test_code_five
  	line = 3
  	assert_output("Line 3: Could not evaluate expression!\n") {@init.exit_five(line, false)}
  end

  # Asserts that the program returns an exit code of five due to an invalid file error.
  def test_code_five_invalid_file
    line = -1
    assert_output("File cannot be found and/or read!\n") {@init.exit_five(line, false)}
  end

  # Asserts that the program returns an exit code of zero due to no errors.
  def test_clean_exit
    code = 0
    assert_output("") {@init.clean_exit(code, false)}
  end
end
