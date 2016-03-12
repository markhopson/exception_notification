require 'httparty'

module ExceptionNotifier
  class OpsgenieNotifier < BaseNotifier
    include HTTParty

    def initialize(options)
      @apikey = options[:apikey]
      @url = options[:url] || "https://api.opsgenie.com/v1/json/alert"
      @recipients = options[:recipients] || '""'
      @teams = options[:teams] || '""'
    end 

    def call(e, options={})
      debugger
      # create description
      msg = e.message.blank? ? 'n/a' : e.message
      clss = e.class.blank? ? 'n/a' : e.class
      bktr = e.backtrace.blank? ? 'n/a' : e.backtrace.map{|s| "\\t#{s}"}.join('\\n') 
      host = `hostname`
      desc = "Message: #{msg}\\n\\n"+
             "Class: #{clss}\\n\\n"+
             "Host: #{host.squish}\\n\\n"+
             "Backtrace:\\n#{bktr}\\n\\n"
      alis = e.backtrace.present? ? e.backtrace[0].tr('^A-Za-z0-9', '') : ''
      
      # send the notification
      body = <<-BODY
        {
          "apiKey": "#{@apikey}",
          "message": "#{e.message}",
          "recipients": #{@recipients.to_s},
          "description": "#{desc.html_safe}",
          "teams": #{@teams.to_s},
          "alias": "#{alis}"
        }
      BODY

      self.class.post(@url, { body: body })
    end
  end
end

