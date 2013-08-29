# encoding: utf-8

require 'net/http'
#require 'json/pure'

class TicketCreater

  def initialize(url, api_key)
    @url = url
    @api_key = api_key
  end

  def ticket_create(target_issue)
    issue = { }
    issue[:project_id] = target_issue.project_id
    issue[:tracker_id] = target_issue.tracker_id
    issue[:subject] = target_issue.subject
    issue[:description] = target_issue.description
    issue[:custom_field_values] = target_issue.custom_field_values.attributes
    issue[:watcher_user_ids] = target_issue.watcher_user_ids
    data = { :issue => issue }.to_json

    if /^(.*)\/$/ =~ @url
      uri = URI.parse(@url + 'issues.json')
    else
      uri = URI.parse(@url + '/issues.json')
    end

    req = Net::HTTP::Post.new(uri.path)
    req.content_type = 'application/json'
    req['X-Redmine-API-Key'] = @api_key
    req.body = data

    #print req,"\n"
    #print req.body,"\n"
    #print uri,"\n"
    #print req['X-Redmine-API-Key'],"\n"

    Net::HTTP.start(uri.host, uri.port){ |http|
      res = http.request(req)

      case res.code.to_i
      when 201
        return true, JSON.parse(res.body)["issue"]
        #puts "Success: Create New Issue「##{ new_issue['id']} #{ new_issue['subject'] }」"
      when 422
        return false, "CODE: #{ res.code } #{ JSON.parse(res.body)['errors'].join(', ') }"
        #puts "Error: #{ res.code } #{ JSON.parse(res.body)['errors'].join(', ') }"
      else
        return false, "CODE: #{ res.code } #{res.message} #{ res.body }"
        #puts "Error: #{ res.code } #{res.message} #{ res.body }"
      end
    }
  end
end
