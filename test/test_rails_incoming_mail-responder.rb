require 'minitest/autorun'
require 'rails_incoming_mail'

class RailsIncomingMailResponderTest < Minitest::Unit::TestCase
  def setup
    @r = RailsIncomingMail::Responder.new("the.domain")
  end

  def test_should_respond_to_ehlo
    assert_equal "250 the.domain\r\n", @r.process_line("EHLO whatever")
  end

  def test_should_respond_to_quit
    assert_equal "", @r.process_line("QUIT")
    assert_equal false, Thread.current[:connection_active]
  end

  def test_should_process_mail_from
    assert_equal "250 Ok\r\n", @r.process_line("MAIL FROM:<from@email.com>")
    assert_equal "<from@email.com>", Thread.current[:message][:from]
  end

  def test_should_process_rcpt_to
    assert_equal "250 Ok\r\n", @r.process_line("RCPT TO:<to@email.com>")
    assert_equal ["<to@email.com>"], Thread.current[:message][:to]
  end

  def test_should_accept_multiple_recipients
    @r.process_line("RCPT TO:<one@email.com>")
    @r.process_line("RCPT TO:<two@email.com>")
    assert_equal 2, Thread.current[:message][:to].length
  end
end