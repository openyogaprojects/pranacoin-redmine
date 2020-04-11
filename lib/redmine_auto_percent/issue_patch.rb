module RedmineAutoPercent
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        before_save :custom_field_set_value
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    class BitcoinRPC
      def initialize(service_url)
        @uri = URI.parse(service_url)
      end

      def method_missing(name, *args)
        post_body = { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
        resp = JSON.parse( http_post_request(post_body) )
        raise JSONRPCError, resp['error'] if resp['error']
        resp['result']
      end

      def http_post_request(post_body)
        http    = Net::HTTP.new(@uri.host, @uri.port)
        request = Net::HTTP::Post.new(@uri.request_uri)
        request.basic_auth @uri.user, @uri.password
        request.content_type = 'application/json'
        request.body = post_body
        http.request(request).body
      end

      class JSONRPCError < RuntimeError
      end

    end

    def custom_field_set_value
      if !self.assigned_to.nil? && !self.done_ratio.zero? && self.status.is_closed?
        tx = self.custom_field_value(4)
        self.custom_field_values.each do |field|
          if  ( field.custom_field.id == 2 )
            h = BitcoinRPC.new('http://user:pass@host:21710')
            address = self.assigned_to.custom_field_value(3)
            maxsalary = field.value.to_f
            ln_from_maxsalary = Math.log(maxsalary)
            salary = Math.exp( ln_from_maxsalary / 100 * self.done_ratio )
              if !maxsalary.zero? && !address.blank? && tx.blank?
                account = "redmine"
                tx = h.sendfrom(account, address, salary)
              end
          end
          if ( field.custom_field.id == 4 )
            field.value = tx
          end
        end
      end
    end
  end
end
