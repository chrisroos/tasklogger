require 'task'

class TaskLogger
  
  TIME_FORMAT = "%Y-%m-%d %H:%M"
  
  def initialize(tasks_path)
    @tasks_path = tasks_path
  end
  
  def start(task_description)
    task = Task.new(task_description)
    if last_task_data = tasks.pop
      last_task = Task.from_array(last_task_data)
      last_task.finish!
      tasks << last_task.to_a
    end
    tasks << task.to_a
    write_tasks
  end
  
  def resume
    exit_if_missing_data
    
    last_task_data        = tasks.pop
    last_task             = Task.from_array(last_task_data)
    last_task.finish!

    penultimate_task_data = tasks.last
    penultimate_task      = Task.from_array(penultimate_task_data)
    penultimate_task.restart!

    tasks << last_task.to_a
    tasks << penultimate_task.to_a

    write_tasks
  end
  
  def list
    exit_if_missing_data
    
    tasks[-5, 5].each do |task|
      puts task.to_csv
    end
  end
  
  private
  
    def tasks
      @tasks ||= File.exists?(@tasks_path) ? FasterCSV.read(@tasks_path) : []
    end
    
    def exit_if_missing_data
      if tasks.empty?
        puts "Error. The timelog data cannot be found."
        exit 1
      end
    end
    
    def write_tasks
      File.open(@tasks_path, 'w') do |file|
        tasks.each do |task|
          file.puts task.to_csv
        end
      end
    end
    
end