require 'minitest/autorun'
require 'rails_incoming_mail'

class RailsIncomingMailServerTest < Minitest::Test

  def setup
    @s = RailsIncomingMail::Server.new("the.domain")
  end

  def test_serve

  end
end