require_relative 'arg_checker'
require_relative 'init_errors'
ac = ArgsChecker.new
values = ac.check_args(ARGV)
unless values.empty?
  ie = InitErrors.new
  ie.clean_exit(values[0], true) if values[0].zero?
  ie.exit_five(values[2], true) if values[0] == 5
  ie.call_error(values[0], values[1], values[2], true)
end
