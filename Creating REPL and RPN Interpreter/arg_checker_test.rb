require 'minitest/autorun'
require_relative 'arg_checker'

class ArgCheckerTest < Minitest::Test

  def setup
    @arg_checker = ArgsChecker.new
  end
  
  # Asserts that run repl is called when no arguments are provided.
  # Have to use a mock due to repl causing an infinite loop when called from a test
  def test_check_args_repl
    input = []
    @arg_checker.stub :run_repl, true do
      assert(@arg_checker.check_args(input))
    end
  end
  
  # Asserts that check_args returns an error when there's a nonexistent file
  def test_check_args_file_nonexist
    file_args = ["../CS1632_Deliverable6/File69.rpn"]
    assert_equal @arg_checker.check_args(file_args), [5, 0, -1]
  end

  # Asserts that check_args returns an error when there's a file with an incorrect extension
  def test_check_args_incorrect_extension
    file_args = ["../CS1632_Deliverable6/File1.gupta"]
    assert_equal @arg_checker.check_args(file_args), [5, 0, -1]
  end
  
  # Asserts that check_args will process a valid file
  # Requires File1.rpn to remain unchanged
  def test_check_args_file_valid
    file_args = ["../CS1632_Deliverable6/File1.rpn"]
    val = 0
    assert_output("3\n") {val = @arg_checker.check_args(file_args)}
    assert val.is_a?(Array)
  end

  # Asserts that existing files are accepted by read_file
  def test_check_existent_file
    file_args = ["../CS1632_Deliverable6/File1.rpn"]
    val = 0
    assert_output("") {val = @arg_checker.read_file(file_args)}
    assert_equal val, [["LET A 1", "LET B 2", "PRINT A B +"]]
  end

  # Asserts that nonexistent files are rejected by read_file
  def test_check_nonexistent_file
    file_args = ["../CS1632_Deliverable6/File69.rpn"]
    assert_equal @arg_checker.read_file(file_args), 'INV'
  end

  # Asserts that files with correct extensions are accepted by check_array_arguments
  def test_check_correct_file_extension
    file_args = ["../CS1632_Deliverable6/File1.rpn"]
    assert_output("") {@arg_checker.check_array_arguments(file_args)}
  end
  
  # Asserts that files with incorrect extensions are rejected by check_array_arguments
  def test_check_incorrect_file_extension
    file_args = ["../CS1632_Deliverable6/File1.gupta"]
    assert_equal @arg_checker.check_array_arguments(file_args), [5, 0, -1]
  end

  # Asserts that an invalid file will be rejected from among valid files by read_file
  def test_multiple_correct_files_provided
    file_args = ["File1.rpn File2.rpn File3.rpn"]
    assert_equal @arg_checker.read_file(file_args), 'INV'
  end

  # Asserts that LET in do_file_math throws an error
  def test_do_file_math_let_keyword
    val = @arg_checker.do_file_math(['LET'])
    assert_equal val, []
    assert_equal [5, 0, 0], @arg_checker.error_data
  end
  
  # Asserts that PRINT in do_file_math throws an error
  def test_do_file_math_print_keyword
    val = @arg_checker.do_file_math(['PRINT'])
    assert_equal val, []
    assert_equal [5, 0, 0], @arg_checker.error_data
  end

  # Asserts that QUIT in do_file_math throws an error
  def test_do_file_math_quit_keyword
    val = @arg_checker.do_file_math(['QUIT'])
    assert_equal val, []
    assert_equal [5, 0, 0], @arg_checker.error_data
  end

  # Asserts that an empty input returns an empty array
  def test_do_file_math_empty
    val = @arg_checker.do_file_math([])
    assert_equal val, []
  end

  # Asserts that branches accepts a valid LET statement
  def test_branches_valid_let
    input = ["LET", "A", "1"]
    assert_nil @arg_checker.branches(input)
  end

  # Asserts that branches rejects an invalid LET statement
  def test_branches_invalid_let
    input = ["LET", "A", "1", "+"]
    assert_equal 'INV', @arg_checker.branches(input)
  end

  # Asserts that nil is returned by check_first_element when provided an empty input array.
  def test_check_first_element_input_empty
    input = []
    assert_nil @arg_checker.check_first_element(input)
  end
  
  # Asserts that check_first_element properly saves a variable when given a valid LET statement
  def test_check_first_element_input_let
    input = ["LET", "A", "1",  "0",  "+"]
    val = 0
    assert_output("1\n") {val = @arg_checker.check_first_element(input)}
    assert_equal val, true
    assert_equal 1, @arg_checker.map['A']
  end
  
  # Asserts that check_first_element does the math for a valid PRINT statement
  def test_check_first_element_input_print
    input = ["PRINT", "1", "1", "+"]
    val = 0
    assert_output("") {val = @arg_checker.check_first_element(input)}
    assert_equal val, true
    assert_equal [2], @arg_checker.stack
  end  
  
  # Asserts that define_variable returns an error when provided with a LET statement without a variable
  def test_define_variable_nil
    input = ["LET"]
    assert_output("Line 0: Could not evaluate expression\n") {@arg_checker.define_variable(input)}
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_variable returns an error when provided with an invalid variable name and that variable is not initialized
  def test_define_variable_question_mark
    input = ["LET", "?", "1"]
    assert_output("Line 0: Could not evaluate expression\n") {@arg_checker.define_variable(input)}
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_variable returns an error when provided with an invalid variable name and that variable is not initialized
  def test_define_variable_laboon
    input = ["LET", "laboon", "1"]
    assert_output("Line 0: Could not evaluate expression\n") {@arg_checker.define_variable(input)}
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_variable returns an error when provided with a LET statement with no RPN expression and that variable is not initialized
  def test_define_variable_no_rpn
    input = ["LET", "a"]
    assert_output("Line 0: Could not evaluate expression\n") {@arg_checker.define_variable(input)}
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_variable returns an error when provided with a LET statement with an invalid RPN expression and that variable is not initialized
  def test_define_variable_no_operator_rpn
    input = ["LET", "a", "1", "1"]
    assert_output("Line 0: 2 elements in stack after evaluation\n") {@arg_checker.define_variable(input)}
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_variable returns an error when provided with a LET statement with an invalid RPN expression and that variable is not initialized
  def test_define_variable_empty_stack_rpn
    input = ["LET", "a", "1", "+"]
    assert_output("Line 0: Operator + applied to empty stack\n") {@arg_checker.define_variable(input)}
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_variable outputs the value of the LET statement and initializes the variable
  def test_define_variable_valid
    input = ["LET", "A", "1", "1", "+"]
    assert_output("2\n") {@arg_checker.define_variable(input)}
    assert_equal 2, @arg_checker.map["A"]
  end

  # Asserts that the correct error message is displayed for code 1.
  def test_call_error_code_one
    code = 1
    var = 'A'
    assert_output("Line 0: Variable A is not initialized\n") {@arg_checker.call_error(code, var)}
  end
  
  # Asserts that the correct error message is displayed for code 2.
  def test_call_error_code_two
    code = 2
    var = '+'
    assert_output("Line 0: Operator + applied to empty stack\n") {@arg_checker.call_error(code, var)}
  end
  
  # Asserts that the correct error message is displayed for code 3.
  def test_call_error_code_three
    code = 3
    var = 3
    assert_output("Line 0: 3 elements in stack after evaluation\n") {@arg_checker.call_error(code, var)}
  end
  
  # Asserts that the correct error message is displayed for code 4.
  def test_call_error_code_four
    code = 4
    var = 'laboon'
    assert_output("Line 0: Unknown keyword laboon\n") {@arg_checker.call_error(code, var)}
  end
  
  # Asserts that the correct error message is displayed for code 5.
  def test_call_error_code_five
    code = 5
    var = nil
    assert_output("Line 0: Could not evaluate expression\n") {@arg_checker.call_error(code, var)}
  end

  # Asserts that handle_input returns quit when the first keyword is QUIT
  def test_handle_input_quit
    input = 'QUIT'
    val = @arg_checker.handle_input(input)
    assert_equal val, 'QUIT'
  end

  # Asserts that handle_input throws an error when provided with an unknown keyword
  def test_handle_input_unkown_keyword
    input = 'LET CDD 27'
    assert_output("Line 1: Unknown keyword CDD\n") {@arg_checker.handle_input(input)}
  end
  
  # Asserts that handle_input outputs the correct value when provided with a valid input
  def test_handle_input_valid
    input = '1 1 +'
    assert_output("2\n") {@arg_checker.handle_input(input)}
  end

  # Asserts that init_operands throws an error when there's an empty stack
  def test_init_operands_empty
    input = '+'
    val = 0
    assert_output("Line 0: Operator + applied to empty stack\n") {val = @arg_checker.init_operands(input)}
    assert_equal [], val
  end
  
  # Asserts that init_operands returns the values from the stack as ints
  def test_init_operands_valid
    @arg_checker.stack = ["1", "0"]
    input = '+'
    val = 0
    assert_output("") {val = @arg_checker.init_operands(input)}
    assert_equal [0, 1], val
  end

  # Asserts that subtraction is handled properly by handle_operators when there is an empty stack
  def test_handle_operators_subtract_empty
    input = '-'
    val = 0
    assert_output("Line 0: Operator - applied to empty stack\n") {val = @arg_checker.handle_operators(input)}
    assert_equal false, val
  end

  # Asserts that handle_operators throws an error when asked to divide by zero
  def test_handle_operators_division_by_zero
    @arg_checker.stack = ["1", "0"]
    input = '/'
    val = 0
    assert_output("Line 0: Could not evaluate expression\n") {val = @arg_checker.handle_operators(input)}
    assert_equal val, false
  end
  
  # Asserts that handle_operators adds properly
  def test_handle_operators_add_valid
    @arg_checker.stack = ["1", "1"]
    input = '+'
    val = 0
    assert_output("") {val = @arg_checker.handle_operators(input)}
    assert_equal val, true
    assert_equal [2], @arg_checker.stack
  end
  
  # Asserts that handle_operators subtracts properly
  def test_handle_operators_subtract_valid
    @arg_checker.stack = ["2", "1"]
    input = '-'
    val = 0
    assert_output("") {val = @arg_checker.handle_operators(input)}
    assert_equal val, true
    assert_equal [1], @arg_checker.stack
  end
  
  # Asserts that handle_operators multiplies properly
  def test_handle_operators_multiply_valid
    @arg_checker.stack = ["3", "6"]
    input = '*'
    val = 0
    assert_output("") {val = @arg_checker.handle_operators(input)}
    assert_equal val, true
    assert_equal [18], @arg_checker.stack
  end
  
  # Asserts that handle_operators divides properly
  def test_handle_operators_division_valid
    @arg_checker.stack = ["10", "2"]
    input = '/'
    val = 0
    assert_output("") {val = @arg_checker.handle_operators(input)}
    assert_equal val, true
    assert_equal [5], @arg_checker.stack
  end

  # Asserts that parse_file_line returns nil on an empty input
  def test_parse_file_line_empty
    input = []
    assert_nil @arg_checker.parse_file_line(input)
  end

  # Asserts that parse_file_line returns INV and a clean exit code when QUIT is the first keyword
  def test_parse_file_line_quit
    input = ['QUIT']
    assert_equal @arg_checker.parse_file_line(input), 'INV'
    assert_equal [0, 0, 0], @arg_checker.error_data
  end
  
  # Asserts that parse_file_line returns an error when provided with an unknown keyword
  def test_parse_file_line_wrong_keyword
    input = ['Magic']
    assert_equal @arg_checker.parse_file_line(input), 'INV'
    assert_equal [4, "Magic", 0], @arg_checker.error_data
  end
  
  # Asserts that parse_file_line doesn't throw an error for any of the acceptable types of input
  def test_parse_file_line_valid_all
    input = ["LET", "PRINT", "1", "-1", "200", "999999999999999999999999999999999999", "+", "-", "/", "*", "a", "Z"]
    val = @arg_checker.parse_file_line(input)
    assert_equal val, input
  end
  
  # Asserts that handle_more prints out the stack when there's a keyword at the beginning of the statement
  def test_handle_more_true
    @arg_checker.stack = [2]
    input = ["PRINT", "1", "1", "+"]
    val = true
    assert_output("2\n") {@arg_checker.handle_more(input, val)}
  end
  
  # Asserts that handle_more throws an error when there are elements left on the stack after doing math
  def test_handle_more_no_operator_rpn
    input = ["1", "1"]
    val = false
    assert_output("Line 0: 2 elements in stack after evaluation\n") {@arg_checker.handle_more(input, val)}
  end

  # Asserts that handle_more prints out the stack after doing math on a valid statement
  def test_handle_more_valid
    input = ["1", "1", "+"]
    val = false
    assert_output("2\n") {@arg_checker.handle_more(input, val)}
    assert_equal 2, @arg_checker.stack[0]
  end
  
  # Asserts that do_math throws an error when there is a keyword in the middle of a statement
  def test_do_math_middle_keyword
    input = ["1", "PRINT", "+"]
    val = 0
    assert_output("Line 0: Could not evaluate expression\n") {val = @arg_checker.do_math(input)}
    assert_equal [], val
  end
  
  # Asserts that do_math throws an error when there is an empty stack for an operator
  def test_do_math_empty_stack
    input = ["1", "+"]
    val = 0
    assert_output("Line 0: Operator + applied to empty stack\n") {val = @arg_checker.do_math(input)}
    assert_equal [], val
  end
  
  # Asserts that do_math returns an stack with extra elements when there were not enough operators
  def test_do_math_missing_operator
    input = ["1", "1", "1", "+"]
    assert_equal ["1", 2], @arg_checker.do_math(input)
  end
  
  # Asserts that do_math throws an error when attempting to divide by zero
  def test_do_math_divide_by_zero
    input = ["1", "0", "/"]
    val = 0
    assert_output("Line 0: Could not evaluate expression\n") {val = @arg_checker.do_math(input)}
    assert_equal [], val
  end
  
  # Asserts that do_math throws an error when attempting to use an unitialized variable
  def test_do_math_unitialized_variable
    input = ["a", "1", "+"]
    val = 0
    assert_output("Line 0: Variable a is not initialized\n") {val = @arg_checker.do_math(input)}
    assert_equal [], val
  end
  
  # Asserts that do_math works on a valid statement that includes all valid operators
  def test_do_math_valid
    input = ["1", "1", "1", "1", "1", "-", "+", "*", "/"]
    assert_equal [1], @arg_checker.do_math(input)
  end
  
  # Asserts that do_math works with an initialized variable
  def test_do_math_valid_variable
    @arg_checker.map["A"] = 1
    input = ["a"]
    val=0
    assert_output("") {val = @arg_checker.do_math(input)}
    assert_equal [1], @arg_checker.stack
  end
  
  # Asserts that init_operands throws an error when given a stack with too few operands
  def test_init_operands_one
    @arg_checker.stack = ["1"]
    opt = "+"
    val = 0
    assert_output("Line 0: Operator + applied to empty stack\n") {val = @arg_checker.init_operands(opt)}
    assert_equal [], val
  end
  
  #Asserts that init_operands returns a filled array when provided with a filled stack
  def test_init_operands_two
    @arg_checker.stack = ["1", "1"]
    opt = "+"
    assert_equal [1, 1], @arg_checker.init_operands(opt)
  end
  
  # Asserts that init_operands returns the last two variables of the stack reversed
  def test_init_operands_three
    @arg_checker.stack = ["1", "2", "3"]
    opt = "+"
    assert_equal [3, 2], @arg_checker.init_operands(opt)
  end
  
  # Asserts that execute_rpn returns the correct output for a single file
  def test_execute_rpn_valid_one
    input = [["LET A 1", "LET B 2", "PRINT A B +"]]
    val = 0
    assert_output("3\n") {val = @arg_checker.execute_rpn(input)}
    assert_equal [], val
  end
  
  # Asserts that execute_rpn returns the correct output for multiple files
  def test_execute_rpn_valid_two
    input = [["LET A 1", "LET B 2", "PRINT A B +"], ["PRINT -1 1 +"]]
    val = 0
    assert_output("3\n0\n") {val = @arg_checker.execute_rpn(input)}
    assert_equal [], val
  end
  
  # Asserts that execute_rpn returns an error for a file with an invalid keyword
  def test_execute_rpn_unknown_keyword
    input = [["LET A 1", "APPLE", "PRINT A B +"], ["PRINT -1 1 +"]]
    val = 0
    assert_output("") {val = @arg_checker.execute_rpn(input)}
    assert_equal [4, "APPLE", 2], val
  end
  
  # Asserts that execute_rpn returns an error for a file with an unitialized variable error
  def test_execute_rpn_other_error
    input = [["LET A 1", "LET B 2", "PRINT A B +"], ["PRINT C"]]
    val = 0
    assert_output("3\n") {val = @arg_checker.execute_rpn(input)}
    assert_equal [1, "C", 4], val
  end
  
  #Asserts that execute_rpn returns a clean exit code when a file QUITs, and doesn't follow any instructions afterwards
  def test_execute_rpn_quit
    input = [["LET A 1", "LET B 2", "PRINT A B +"], ["QUIT", "PRINT 1"]]
    val = 0
    assert_output("3\n") {val = @arg_checker.execute_rpn(input)}
    assert_equal [0, 0, 0], val
  end
  
  # Asserts that define_file_variable returns an error when provided with a LET statement without a variable
  def test_define_file_variable_nil
    input = ["LET"]
    val = 0
    assert_output("") {val = @arg_checker.define_file_variable(input)}
    assert_equal 'INV', val
    assert_equal [5, 0, 0], @arg_checker.error_data
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_file_variable returns an error when provided with an invalid variable name and that variable is not initialized
  def test_define_file_variable_question_mark
    input = ["LET", "?", "1"]
    val = 0
    assert_output("") {val = @arg_checker.define_file_variable(input)}
    assert_equal 'INV', val
    assert_equal [5, 0, 0], @arg_checker.error_data
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_file_variable returns an error when provided with an invalid variable name and that variable is not initialized
  def test_define_file_variable_laboon
    input = ["LET", "laboon", "1"]
    val = 0
    assert_output("") {val = @arg_checker.define_file_variable(input)}
    assert_equal 'INV', val
    assert_equal [5, 0, 0], @arg_checker.error_data
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_file_variable returns an error when provided with a LET statement with no RPN expression and that variable is not initialized
  def test_define_file_variable_no_rpn
    input = ["LET", "a"]
    val = 0
    assert_output("") {val = @arg_checker.define_file_variable(input)}
    assert_equal 'INV', val
    assert_equal [5, 0, 0], @arg_checker.error_data
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_file_variable returns an error when provided with a LET statement with an invalid RPN expression and that variable is not initialized
  def test_define_file_variable_no_operator_rpn
    input = ["LET", "a", "1", "1"]
    val = 0
    assert_output("") {val = @arg_checker.define_file_variable(input)}
    assert_equal 'INV', val
    assert_equal [3, 2, 0], @arg_checker.error_data
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_file_variable returns an error when provided with a LET statement with an invalid RPN expression and that variable is not initialized
  def test_define_file_variable_empty_stack_rpn
    input = ["LET", "a", "1", "+"]
    val = 0
    assert_output("") {val = @arg_checker.define_file_variable(input)}
    assert_equal 'INV', val
    assert_equal [2, "+", 0], @arg_checker.error_data
    assert_equal Hash.new, @arg_checker.map
  end
  
  # Asserts that define_file_variable outputs the value of the LET statement and initializes the variable
  def test_define_file_variable_valid
    input = ["LET", "A", "1", "1", "+"]
    val = 0
    assert_output("") {val = @arg_checker.define_file_variable(input)}
    assert_equal [], val
    assert_equal [], @arg_checker.error_data
    assert_equal 2, @arg_checker.map["A"]
  end
  
  # Asserts that do_more_math adds an initialized variable to the stack
  def test_do_more_math_valid
    @arg_checker.map["A"] = 1
    input = "a"
    val=0
    assert_output("") {val = @arg_checker.do_more_math(input)}
    assert_equal [], @arg_checker.error_data
    assert_equal true, val
    assert_equal [1], @arg_checker.stack
  end
  
  # Asserts that do_more_math returns an error when a variable is not initialized
  def test_do_more_math_invalid
    input = "a"
    val=0
    assert_output("") {val = @arg_checker.do_more_math(input)}
    assert_equal [1, "a", 0], @arg_checker.error_data
    assert_equal false, val
    assert_equal [], @arg_checker.stack
  end
  
  # Asserts that do_file_math throws an error when there is a keyword in the middle of a statement
  def test_do_file_math_middle_keyword
    input = ["1", "PRINT", "+"]
    val = 0
    assert_output("") {val = @arg_checker.do_file_math(input)}
    assert_equal [], val
    assert_equal [5, 0, 0], @arg_checker.error_data
  end
  
  # Asserts that do_file_math throws an error when there is an empty stack for an operator
  def test_do_file_math_empty_stack
    input = ["1", "+"]
    val = 0
    assert_output("") {val = @arg_checker.do_file_math(input)}
    assert_equal [], val
    assert_equal [2, "+", 0], @arg_checker.error_data
  end
  
  # Asserts that do_file_math returns an stack with extra elements when there were not enough operators
  def test_do_file_math_missing_operator
    input = ["1", "1", "1", "+"]
    assert_equal ["1", 2], @arg_checker.do_file_math(input)
    assert_equal [], @arg_checker.error_data
  end
  
  # Asserts that do_file_math throws an error when attempting to divide by zero
  def test_do_file_math_divide_by_zero
    input = ["1", "0", "/"]
    val = 0
    assert_output("") {val = @arg_checker.do_file_math(input)}
    assert_equal [], val
    assert_equal [5, 0, 0], @arg_checker.error_data
  end
  
  # Asserts that do_file_math throws an error when attempting to use an unitialized variable
  def test_do_file_math_unitialized_variable
    input = ["a", "1", "+"]
    val = 0
    assert_output("") {val = @arg_checker.do_file_math(input)}
    assert_equal [], val
    assert_equal [1, "a", 0], @arg_checker.error_data
  end
  
  # Asserts that do_math works on a valid statement that includes all valid operators
  def test_do_file_math_valid
    input = ["1", "1", "1", "1", "1", "-", "+", "*", "/"]
    assert_equal [1], @arg_checker.do_file_math(input)
    assert_equal [], @arg_checker.error_data
  end
  
  # Asserts that do_math works with an initialized variable
  def test_do_file_math_valid_variable
    @arg_checker.map["A"] = 1
    input = ["a", "1", "+"]
    assert_output("") {@arg_checker.do_file_math(input)}
    assert_equal [2], @arg_checker.stack
    assert_equal [], @arg_checker.error_data
  end
  
  # Asserts that handle_file_operators throws an error when dealing with an empty stack
  def test_handle_file_operators_empty_operands
    input = "+"
    val = 0
    assert_output("") {val = @arg_checker.handle_file_operators(input)}
    assert_equal false, val
    assert_equal [2, "+", 0], @arg_checker.error_data
  end
  
  # Asserts that handle_file_operators throws an error when asked to divide by zero
  def test_handle_file_operators_divide_by_zero
    @arg_checker.stack = ["1", "0"]
    input = "/"
    val = 0
    assert_output("") {val = @arg_checker.handle_file_operators(input)}
    assert_equal false, val
    assert_equal [5, 0, 0], @arg_checker.error_data
  end
  
  # Asserts that handle_file_operators handles a valid statement
  def test_handle_file_operators_valid
    @arg_checker.stack = ["5", "3"]
    input = "-"
    val = 0
    assert_output("") {val = @arg_checker.handle_file_operators(input)}
    assert_equal true, val
    assert_equal [], @arg_checker.error_data
    assert_equal [2], @arg_checker.stack
  end
  
  # Asserts that init_file_operands throws an error when given a stack with too few operands
  def test_init_file_operands_one
    @arg_checker.stack = ["5"]
    input = "-"
    val = 0
    assert_output("") {val = @arg_checker.init_file_operands(input)}
    assert_equal [], val
    assert_equal [2, "-", 0], @arg_checker.error_data
  end
  
  #Asserts that init_file_operands returns a filled array when provided with a filled stack
  def test_init_file_operands_two
    @arg_checker.stack = ["5", "3"]
    input = "-"
    val = 0
    assert_output("") {val = @arg_checker.init_file_operands(input)}
    assert_equal [3, 5], val
    assert_equal [], @arg_checker.error_data
  end
  
  # Asserts that init_file_operands returns the last two variables of the stack reversed
  def test_init_file_operands_three
    @arg_checker.stack = ["5", "3", "1"]
    input = "-"
    val = 0
    assert_output("") {val = @arg_checker.init_file_operands(input)}
    assert_equal [1, 3], val
    assert_equal [], @arg_checker.error_data
    assert_equal ["5"], @arg_checker.stack
  end
  
  # Asserts that check_first_file_element returns nil when given an empty input
  def test_check_first_file_element_nil
    input = []
    val = 0
    assert_output("") {val = @arg_checker.check_first_file_element(input)}
    assert_nil val
  end
  
  # Asserts that check_first_file_element returns nil when given a valid LET statement
  def test_check_first_file_element_valid_let
    input = ["LET", "A", "1"]
    val = 0
    assert_output("") {val = @arg_checker.check_first_file_element(input)}
    assert_nil val
  end
  
  # Asserts that check_first_file_element returns 'INV' when given an invalid LET statement
  def test_check_first_file_element_invalid_let
    input = ["LET", "A"]
    val = 0
    assert_output("") {val = @arg_checker.check_first_file_element(input)}
    assert_equal 'INV', val
  end
  
  # Asserts that check_first_file_element returns nil and outputs the correct value when given a valid PRINT statement
  def test_check_first_file_element_valid_print
    input = ["PRINT", "1"]
    val = 0
    assert_output("1\n") {val = @arg_checker.check_first_file_element(input)}
    assert_nil val
  end
  
  # Asserts that check_first_file_element throws an error and returns 'INV' when given an invalid PRINT statement
  def test_check_first_file_element_empty_stack_print
    input = ["PRINT", "1", "+"]
    val = 0
    assert_output("") {val = @arg_checker.check_first_file_element(input)}
    assert_equal 'INV', val
    assert_equal [2, "+", 0], @arg_checker.error_data
  end
  
  # Asserts that check_first_file_element throws an error and returns 'INV' when given an invalid PRINT statement
  def test_check_first_file_element_no_operator_print
    input = ["PRINT", "1", "1"]
    val = 0
    assert_output("") {val = @arg_checker.check_first_file_element(input)}
    assert_equal 'INV', val
    assert_equal [3, 2, 0], @arg_checker.error_data
  end
  
  # Asserts that check_first_file_element returns nil when given a valid statement without a keyword
  def test_check_first_file_element_valid_none
    input = ["1", "1", "+"]
    val = 0
    assert_output("") {val = @arg_checker.check_first_file_element(input)}
    assert_nil val
  end
  
  # Asserts that check_first_file_element returns 'INV' and throws an error when given an invalid statement without a keyword
  def test_check_first_file_element_invalid_none
    input = ["1", "1"]
    val = 0
    assert_output("") {val = @arg_checker.check_first_file_element(input)}
    assert_equal 'INV', val
    assert_equal [3, 2, 0], @arg_checker.error_data
  end
  
  # Asserts that parse_line returns nil on an empty input
  def test_parse_line_empty
    input = []
    val = 0
    assert_output("") {val = @arg_checker.parse_line(input)}
    assert_nil val
  end
  
  # Asserts that parse_line returns INV and a clean exit code when QUIT is the first keyword, and ignores all values after the QUIT
  def test_parse_line_quit
    input = ["quit", "hello"]
    val = 0
    assert_output("") {val = @arg_checker.parse_line(input)}
    assert_equal val, 'QUIT'
  end
  
  # Asserts that parse_line returns an error when provided with an unknown keyword
  def test_parse_line_wrong_keyword
    input = ["1", "hello", "+"]
    val = 0
    assert_output("Line 0: Unknown keyword hello\n") {val = @arg_checker.parse_line(input)}
    assert_equal val, 'INV'
  end
  
  # Asserts that parse_line returns an error when provided with a decimal number
  def test_parse_line_decimal
    input = ["1", "1.0", "+"]
    val = 0
    assert_output("Line 0: Unknown keyword 1.0\n") {val = @arg_checker.parse_line(input)}
    assert_equal val, 'INV'
  end
  
  # Asserts that parse_line doesn't throw an error for any of the acceptable types of input
  def test_parse_line_valid_all
    input = ["LET", "PRINT", "1", "-1", "200", "999999999999999999999999999999999999", "+", "-", "/", "*", "a", "Z"]
    val = 0
    assert_output("") {val = @arg_checker.parse_line(input)}
    assert_equal val, input
  end
  
  # Asserts that the program can handle large numbers
  def test_large_numbers
    input = "999999999999999999 999999999999999999 *"
    assert_output("999999999999999998000000000000000001\n") {@arg_checker.handle_input(input)}
  end
  
  # Asserts that variables are case insensitive
  def test_variable_case_insensitive
    input = 'LET A 1'
    assert_output("1\n") {@arg_checker.handle_input(input)}
    input = 'a'
    assert_output("1\n") {@arg_checker.handle_input(input)}
    input = 'LET b 2'
    assert_output("2\n") {@arg_checker.handle_input(input)}
    input = 'B'
    assert_output("2\n") {@arg_checker.handle_input(input)}
  end
  
  # Asserts that keywords are case insensitive
  def test_keyword_case_insensitive
    input = 'LET A 1'
    assert_output("1\n") {@arg_checker.handle_input(input)}
    input = 'let B 2'
    assert_output("2\n") {@arg_checker.handle_input(input)}
    input = 'LeT C 3'
    assert_output("3\n") {@arg_checker.handle_input(input)}
  end
  
  # Asserts that PRINT doesn't do any additional work in REPL mode
  def test_repl_print
    input = 'PRINT 1 1 +'
    assert_output("2\n") {@arg_checker.handle_input(input)}
    input = '1 1 +'
    assert_output("2\n") {@arg_checker.handle_input(input)}
  end
end