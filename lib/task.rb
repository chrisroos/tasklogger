require 'time'

class Task
  
  TIME_FORMAT     = "%Y-%m-%d %H:%M"
  DEFAULT_PROJECT = '<project-name>'
  
  attr_reader   :started_at, :finished_at
  attr_accessor :project, :description
  
  def self.from_array(task_data)
    description = task_data[3]
    started_at  = Time.parse(task_data[0]) if task_data[0]
    finished_at = Time.parse(task_data[1]) if task_data[1]
    project     = task_data[2]
    new(description, started_at, finished_at, project)
  end
  
  def initialize(description, started_at = nil, finished_at = nil, project = nil)
    @started_at  = started_at || Time.now
    @finished_at = finished_at
    @project     = project || DEFAULT_PROJECT
    @description = description
  end
  
  def restart!
    @started_at  = Time.now
    @finished_at = nil
  end
  
  def finish!
    @finished_at = Time.now unless finished?
  end
  
  def to_a
    [formatted_started_at, formatted_finished_at, @project, @description]
  end
  
  private
  
    def finished?
      @finished_at
    end
    
    def formatted_started_at
      @started_at.strftime(TIME_FORMAT) if @started_at
    end

    def formatted_finished_at
      @finished_at.strftime(TIME_FORMAT) if @finished_at
    end
    
end