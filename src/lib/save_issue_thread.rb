require 'thread'
require File.expand_path(File.dirname(__FILE__)) + "/ticket_creater"

class SaveIssueThread

  attr_accessor :count_sum

  PRIORITY = 1
  def initialize(thread_num, timeout, rm_conf)
    @save_issue_q = Queue.new
    @thread_num = thread_num
    @timeout = timeout
    @group = ThreadGroup.new

    @lock = Mutex.new
    self.count_sum = 0
    @count_finished = 0
    @create = TicketCreater.new(rm_conf["url"], rm_conf["api_key"])
  end

  def enq(issue)
    @save_issue_q.push(issue)
    self.count_sum += 1
  end

  def start
    @thread_num.times do |thread_index|
      thread =  Thread.start(thread_index) do |index|
        thread_name = "Thread-" + index.to_s
        while issue = @save_issue_q.pop
          $logger.info "<#{thread_name}>[Start]"
          ## custom_fieldの更新がうまくいかないので外部プログラムで回避
          #if issue.save
          #  $logger.info "<#{thread_name}>[SUCCESS] have saved issue id = #{issue.id}"
          #else
          #  if issue.errors != nil
          #    $logger.info "<#{thread_name}>[FAILURE] can't save issue." +
          #                  issue.inspect +
          #                  issue.errors.to_a.join(',') +
          #                  issue.errors.full_messages.join(',')
          #  else
          #    $logger.info "<#{thread_name}>[FAILURE] can't save issue." +
          #                  issue.inspect
          #  end
          #end
          result, result_body = @create.ticket_create(issue)
          if result
            $logger.info "<#{thread_name}>[SUCCESS] have saved issue id = #{result_body["id"]}"
          else
            $logger.info "<#{thread_name}>[FAILURE] can't save issue. " + result_body + issue.inspect
          end
          @lock.synchronize{
            @count_finished += 1
          }
        end
      end
      thread.priority = PRIORITY
      @group.add(thread)
    end
  end

  def wait_for_finishing
    start_time = Time.now
    while self.count_sum != @count_finished
      raise "waiting timeout!" if Time.now > start_time + @timeout
      count_remain = self.count_sum - @count_finished
      $logger.info "now waiting - #{count_remain} issues remains"
      Thread.pass
      sleep 1
    end
  end
end
