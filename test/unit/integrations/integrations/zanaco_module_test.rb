require 'test_helper'

class ZanacoTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of Zanaco::Notification, Zanaco.notification('name=cody')
  end
end
