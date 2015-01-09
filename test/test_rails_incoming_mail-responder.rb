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

  def test_should_go_in_data_mode_after_data_line
    assert_equal false, Thread.current[:data_mode]
    @r.process_line("DATA")
    assert_equal true, Thread.current[:data_mode]
  end

  def test_should_process_all_lines_as_data_when_in_data_mode
    @r.process_line("DATA")
    @r.process_line("Header:value\r\n")
    assert_equal "Header:value\r\n", @r.message[:data]
    @r.process_line("Header2:value2\r\n")
    assert_equal "Header:value\r\nHeader2:value2\r\n", @r.message[:data]
  end

  def test_should_quit_data_mode_when_line_is_period
    @r.process_line("DATA")
    @r.process_line("Header:value\r\n")
    @r.process_line("\r\n")
    @r.process_line("body\r\n")
    assert_equal true, @r.data_mode?
    @r.process_line(".")
    assert_equal false, @r.data_mode?
  end
end