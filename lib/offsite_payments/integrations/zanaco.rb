require 'offsite_payments/integrations/zanaco/helper'
require 'offsite_payments/integrations/zanaco/notification'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Zanaco

      mattr_accessor :service_url
      self.service_url = 'https://www.example.com'

      def self.notification(post)
        Notification.new(post)
      end

      class Helper < OffsitePayments::Helper
        # Replace with the real mapping
        mapping :account, ''
        mapping :amount, ''

        mapping :order, ''

        mapping :customer, :first_name => '',
                           :last_name  => '',
                           :email      => '',
                           :phone      => ''

        mapping :billing_address, :city     => '',
                                  :address1 => '',
                                  :address2 => '',
                                  :state    => '',
                                  :zip      => '',
                                  :country  => ''

        mapping :notify_url, ''
        mapping :return_url, ''
        mapping :cancel_return_url, ''
        mapping :description, ''
        mapping :tax, ''
        mapping :shipping, ''
      end

      class Notification < OffsitePayments::Notification
        def complete?
          params['']
        end

        def item_id
          params['']
        end

        def transaction_id
          params['']
        end

        # When was this payment received by the client.
        def received_at
          params['']
        end

        def payer_email
          params['']
        end

        def receiver_email
          params['']
        end

        def security_key
          params['']
        end

        # the money amount we received in X.2 decimal.
        def gross
          params['']
        end

        # Was this a test transaction?
        def test?
          params[''] == 'test'
        end

        def status
          params['']
        end

        # Acknowledge the transaction to Zanaco. This method has to be called after a new
        # apc arrives. Zanaco will verify that all the information we received are correct and will return a
        # ok or a fail.
        #
        # Example:
        #
        #   def ipn
        #     notify = ZanacoNotification.new(request.raw_post)
        #
        #     if notify.acknowledge
        #       ... process order ... if notify.complete?
        #     else
        #       ... log possible hacking attempt ...
        #     end
        def acknowledge(authcode = nil)
          payload = raw

          uri = URI.parse(Zanaco.notification_confirmation_url)

          request = Net::HTTP::Post.new(uri.path)

          request['Content-Length'] = "#{payload.size}"
          request['User-Agent'] = "Active Merchant -- http://activemerchant.org/"
          request['Content-Type'] = "application/x-www-form-urlencoded"

          http = Net::HTTP.new(uri.host, uri.port)
          http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless @ssl_strict
          http.use_ssl        = true

          response = http.request(request, payload)

          # Replace with the appropriate codes
          raise StandardError.new("Faulty Zanaco result: #{response.body}") unless ["AUTHORISED", "DECLINED"].include?(response.body)
          response.body == "AUTHORISED"
        end

        private

        # Take the posted data and move the relevant data into a hash
        def parse(post)
          @raw = post.to_s
          for line in @raw.split('&')
            key, value = *line.scan( %r{^([A-Za-z0-9_.-]+)\=(.*)$} ).flatten
            params[key] = CGI.unescape(value.to_s) if key.present?
          end
        end
      end
    end
  end
end
