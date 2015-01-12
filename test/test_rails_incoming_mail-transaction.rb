require 'minitest/autorun'
require "mocha/mini_test"
require 'rails_incoming_mail'

class RailsIncomingMailTransactionTest < Minitest::Test
  def setup
    @r = RailsIncomingMail::Transaction.new("the.domain")
  end

  def test_should_respond_to_ehlo
    assert_equal "250 the.domain\r\n", @r.process_line("EHLO whatever")
  end

  def test_raise_quit_after_quit_command
    assert_raises RailsIncomingMail::Quit do
      @r.process_line("QUIT")
    end
  end

  def test_should_process_mail_from
    assert_equal "250 Ok\r\n", @r.process_line("MAIL FROM:<from@email.com>")
    assert_equal "<from@email.com>", @r.mail_from
  end

  def test_should_process_rcpt_to
    assert_equal "250 Ok\r\n", @r.process_line("RCPT TO:<to@email.com>")
    assert_equal ["<to@email.com>"], @r.rcpt_to
  end

  def test_should_accept_multiple_recipients
    @r.process_line("RCPT TO:<one@email.com>")
    @r.process_line("RCPT TO:<two@email.com>")
    assert_equal 2, @r.rcpt_to.length
  end

  def test_should_go_in_data_mode_after_data_line
    assert_equal false, @r.data_mode
    @r.process_line("DATA")
    assert_equal true, @r.data_mode
  end

  def test_should_process_all_lines_as_data_when_in_data_mode
    @r.process_line("DATA")
    @r.process_line("Header:value\r\n")
    assert_equal "Header:value\r\n", @r.message
    @r.process_line("Header2:value2\r\n")
    assert_equal "Header:value\r\nHeader2:value2\r\n", @r.message
  end

  def test_should_quit_data_mode_when_line_is_period
    @r.process_line("DATA")
    @r.process_line("Header:value\r\n")
    @r.process_line("\r\n")
    @r.process_line("body\r\n")
    assert_equal true, @r.data_mode
    @r.process_line(".")
    assert_equal false, @r.data_mode
  end

  def test_should_notify_of_completed_message
    observer = mock()
    observer.expects(:update).with(:completed).once
    @r.add_observer(observer)

    @r.process_line("MAIL FROM:<from@email.com>")
    @r.process_line("RCPT TO:<one@email.com>")
    @r.process_line("DATA")
    @r.process_line("Header:value\r\n")
    @r.process_line("\r\n")
    @r.process_line("body\r\n")
    @r.process_line(".")
  end

  def test_should_raise_protocol_error
    assert_raises RailsIncomingMail::ProtocolError do
      @r.process_line("this aint good")
    end
  end
end