require 'test/unit'
require 'tempfile'

module TimeLoggerHelper
  TIMELOGGER_BIN = File.join(File.dirname(__FILE__), '..', 'bin', 'tasklogger')
  def new_task(task)
    `#{TIMELOGGER_BIN} "#{task}"`
  end
  def resume_task
    `#{TIMELOGGER_BIN} resume`
  end
  def list_tasks
    `#{TIMELOGGER_BIN} list`
  end
end

class TimeLogNewTaskTest < Test::Unit::TestCase
  include TimeLoggerHelper

  def setup
    @tmpfile            = Tempfile.new('timelog.txt')
    ENV['TIMELOG_DATA'] = @tmpfile.path
  end

  def test_should_start_a_new_task
    time_now = Time.now
    new_task 'first task'

    expected_task_data = [time_now.strftime("%Y-%m-%d %H:%M"), '', '<project-name>', 'first task']

    assert_equal expected_task_data.join(","), @tmpfile.read.split("\n").last
  end

  def test_should_stop_the_previous_task
    task_data = ['2010-01-01 09:00', nil, '<project-name>', 'first task']
    File.open(@tmpfile.path, 'w') { |f| f.puts(task_data.join(',')) }

    time_now = Time.now
    new_task 'second task'

    task_data[1] = time_now.strftime("%Y-%m-%d %H:%M")

    assert_equal task_data.join(","), @tmpfile.read.split("\n").first
  end

  def test_should_not_stop_the_previous_task_if_it_has_already_been_stopped
    task_data = ['2010-01-01 09:00', '2010-01-01 10:00', '<project-name>', 'first task']
    File.open(@tmpfile.path, 'w') { |f| f.puts(task_data.join(',')) }

    new_task 'new task'

    assert_equal task_data.join(','), @tmpfile.read.split("\n").first
  end

  def test_should_create_the_timelog_data_file_if_it_does_not_exist
    # Create a tempfile, grab the filename and close/delete it leaving us with a unique filename of a file that doesn't exist
    tmpfile      = Tempfile.new('timelog.txt')
    tmpfile_path = tmpfile.path
    tmpfile.close!
    assert_equal false, File.exists?(tmpfile_path)
    ENV['TIMELOG_DATA'] = tmpfile_path

    time_now = Time.now
    new_task 'first task'

    expected_task_data = [time_now.strftime("%Y-%m-%d %H:%M"), '', '<project-name>', 'first task']

    assert_equal expected_task_data.join(','), File.read(tmpfile_path).split("\n").first
  end

end

class TimeLogResumeTaskTest < Test::Unit::TestCase
  include TimeLoggerHelper

  def test_should_stop_the_previous_task_and_resume_the_penultimate_task
    tmpfile             = Tempfile.new('timelog.txt')
    ENV['TIMELOG_DATA'] = tmpfile.path

    tasks = []
    tasks <<  ['2010-01-01 09:00', '2010-01-01 10:00', 'My big project', 'long running task']
    tasks <<  ['2010-01-01 10:00', nil, '<project-name>', 'temporary break in task']
    File.open(tmpfile.path, 'w') do |f|
      tasks.each do |task|
        f.puts(task.join(','))
      end
    end

    time_now = Time.now
    resume_task

    tasks.last[1] = time_now.strftime("%Y-%m-%d %H:%M")
    read_tasks = tmpfile.read.split("\n")

    assert_equal 3, read_tasks.length
    assert_equal tasks.last.join(','), read_tasks[1]

    expected_task_data = [time_now.strftime("%Y-%m-%d %H:%M"), '', 'My big project', 'long running task']
    assert_equal expected_task_data.join(','), read_tasks.last
  end

  def test_should_print_an_error_message_if_we_try_to_resume_a_task_when_the_timelog_data_file_does_not_exist
    # Create a tempfile, grab the filename and close/delete it leaving us with a unique filename of a file that doesn't exist
    tmpfile      = Tempfile.new('timelog.txt')
    tmpfile_path = tmpfile.path
    tmpfile.close!
    assert_equal false, File.exists?(tmpfile_path)
    ENV['TIMELOG_DATA'] = tmpfile_path

    output          = resume_task
    expected_output = "Error. The timelog data cannot be found."

    assert_equal expected_output, output.chomp
  end

end

require 'fastercsv'

class TimeLogListTaskTest < Test::Unit::TestCase
  include TimeLoggerHelper

  def test_should_list_last_5_tasks
    tmpfile             = Tempfile.new('timelog.txt')
    ENV['TIMELOG_DATA'] = tmpfile.path

    tasks = []
    (1..9).each do |i| # intentionally only single digits
      tasks <<  ["2010-01-0#{i} 09:00", "2010-01-0#{i} 10:00", "My big project #{i}", "task #{i}"]
    end
    File.open(tmpfile.path, 'w') do |f|
      tasks.each do |task|
        f.puts(task.join(','))
      end
    end

    output          = list_tasks
    expected_output = tasks[4...9].collect { |task| task.to_csv.chomp }

    assert_equal expected_output, output.split("\n")
  end

  def test_should_print_an_error_message_if_we_try_to_list_that_tasks_when_the_timelog_data_file_does_not_exist
    # Create a tempfile, grab the filename and close/delete it leaving us with a unique filename of a file that doesn't exist
    tmpfile      = Tempfile.new('timelog.txt')
    tmpfile_path = tmpfile.path
    tmpfile.close!
    assert_equal false, File.exists?(tmpfile_path)
    ENV['TIMELOG_DATA'] = tmpfile_path

    output          = list_tasks
    expected_output = "Error. The timelog data cannot be found."

    assert_equal expected_output, output.chomp
  end

end