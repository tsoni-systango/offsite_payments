# require 'offsite_payments/integrations/zanaco/helper'
# require 'offsite_payments/integrations/zanaco/notification'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Zanaco

      mattr_accessor :service_url
      self.service_url = 'https://www.example.com'

      def self.notification(post, options = {})
        Notification.new(post, options)
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

        def initialize(post, options = {})
          super
          @secret_key = @options.delete(:credential3)
          self.production_ips = @options.delete(:whitlisted_ips)
        end

        # def complete?
        #   true
        # end

        def amount
          gross
        end

        def currency
          'ZMW'          
        end

        def nrc_no
          params['nrc']
        end

        def transaction_id
          params['tran_id']
        end

        # When was this payment received by the client.
        def received_at
          params['date']
        end

        def student_id
          params['student_id']
        end

        def payee_name
           params['name']
        end

        def recived_security_key
          params['key']
        end

        # the money amount we received in X.2 decimal.
        # zanco is in development and they do not send amount in fraction
        def gross
          params['amount']
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
        def acknowledge
          secure_compare(recived_security_key, @secret_key)
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

        def secure_compare(a, b)
          return false unless a.bytesize == b.bytesize
          l = a.unpack("C#{a.bytesize}")
          res = 0
          b.each_byte { |byte| res |= byte ^ l.shift }
          res == 0
        end
      end

      class XmlResponse
        attr_accessor :status, :message, :transaction_id
        def initialize(*args)
          opts = args.extract_options!
          @status = opts[:status]
          @message = opts[:message]
          @transaction_id = opts[:transaction_id]
        end
      end
      
    end
  end
end
