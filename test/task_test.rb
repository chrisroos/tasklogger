require 'test/unit'
require 'mocha'
require File.join(File.dirname(__FILE__), '..', 'lib', 'task')

class TaskTest < Test::Unit::TestCase
  
  def test_should_default_the_start_time_to_now
    now = Time.now; Time.stubs(:now).returns(now)
    task = Task.new('')
    assert_equal now, task.started_at
  end
  
  def test_should_default_the_finish_time_to_nil
    assert_nil Task.new('').finished_at
  end
  
  def test_should_default_the_project_to_some_template_text
    assert_equal '<project-name>', Task.new('').project
  end
  
  def test_should_allow_the_project_to_be_overwritten
    task = Task.new('')
    task.project = 'my-project'
    assert_equal 'my-project', task.project
  end
  
  def test_should_be_constructed_with_a_description
    task = Task.new('task-description')
    assert_equal 'task-description', task.description
  end
  
  def test_should_allow_the_description_to_be_overwritten
    task = Task.new('task-description')
    task.description = 'updated-task-description'
    assert_equal 'updated-task-description', task.description
  end
  
  def test_should_default_to_the_current_time_when_finishing_a_task
    task = Task.new('')
    now = Time.now; Time.stubs(:now).returns(now)
    task.finish!
    assert_equal now, task.finished_at
  end
  
  def test_should_not_overwrite_the_finish_time_if_already_set
    task = Task.new('')
    now = Time.now; Time.stubs(:now).returns(now)
    task.finish!
    the_future = now + 10; Time.stubs(:now).returns(the_future)
    task.finish!
    assert_equal now, task.finished_at
  end
  
end

class TaskRestartingTest < Test::Unit::TestCase
  
  def setup
    @time_now = Time.now; Time.stubs(:now).returns(@time_now)
    @task     = Task.from_array(['2010-01-01 09:00', '2010-01-01 10:00', 'project-name', 'description'])
    @task.restart!
  end
  
  def test_should_use_the_current_time_as_the_start_time
    assert_equal @time_now, @task.started_at
  end
  
  def test_should_leave_the_finish_time_blank
    assert_nil @task.finished_at
  end
  
  def test_should_retain_the_project_name
    assert_equal 'project-name', @task.project
  end
  
  def test_should_retain_the_project_description
    assert_equal 'description', @task.description
  end
  
end

class TaskFromArrayTest < Test::Unit::TestCase
  
  def setup
    @started_at, @finished_at, @project, @description = '2010-01-01 09:00', '2010-01-01 10:00', 'task-project', 'task-description'
    task_data = [@started_at, @finished_at, @project, @description]
    @task = Task.from_array(task_data)
  end
  
  def test_should_take_the_started_time_from_the_array
    assert_equal Time.parse(@started_at), @task.started_at
  end
  
  def test_should_task_the_finished_time_from_the_array
    assert_equal Time.parse(@finished_at), @task.finished_at
  end
  
  def test_should_task_the_project_from_the_array
    assert_equal @project, @task.project
  end
  
  def test_should_take_the_description_from_the_array
    assert_equal @description, @task.description
  end
  
end

class TaskToArrayTest < Test::Unit::TestCase
  
  def test_should_build_an_array_from_the_task_data
    task_data = ['2010-01-01 10:00', '2010-01-01 10:00', 'task-project', 'task-description']
    task      = Task.from_array(task_data)
    assert_equal task_data, task.to_a
  end
  
end