require 'rubygems'
require 'json'
require 'zabbixapi'

class ZabbixController

  def initialize(conf)
    @zabi = ZabbixApi.connect(:url => conf["url"],
                              :user => conf["user"],
                              :password => conf["password"])
  end
  def get_recent_alert(interval_before_now)
    time_from = Time.now - interval_before_now
    #return @zabi.do_request({:method => 'alert.get',
    #                         :params => {:output    => ["alertid",
    #                                                    "subject",
    #                                                    "message"],
    #                                     :time_from => time_from.to_i},
    #                         :auth   => @zabi.auth })
    result = @zabi.client.api_request({:method => 'alert.get',
                                       :params => {:output    => ["alertid",
                                                                  "subject",
                                                                  "message"],
                                                   :time_from => time_from.to_i}})
    return result
  end
end
