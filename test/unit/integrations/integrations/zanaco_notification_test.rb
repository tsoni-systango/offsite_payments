require 'test_helper'

class ZanacoNotificationTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
    @zanaco = Zanaco::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @zanaco.complete?
    assert_equal "", @zanaco.status
    assert_equal "", @zanaco.transaction_id
    assert_equal "", @zanaco.item_id
    assert_equal "", @zanaco.gross
    assert_equal "", @zanaco.currency
    assert_equal "", @zanaco.received_at
    assert @zanaco.test?
  end

  def test_compositions
    assert_equal Money.new(3166, 'USD'), @zanaco.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @zanaco.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    ""
  end
end
