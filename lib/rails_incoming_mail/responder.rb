module RailsIncomingMail
  class Responder

    def initialize(my_domain)
      Thread.current[:message] = {}
      Thread.current[:message][:to] = []
      @my_domain = my_domain
    end

    def process_line(line)
      case line
      when (/^(HELO|EHLO)/); return process_ehlo
      when (/^QUIT/); return process_quit
      when (/^MAIL FROM\:/); return process_mail_from(line)
      when (/^RCPT TO\:/); return process_rcpt_to(line)
      when (/^DATA/); return process_data
      end
      
      # If we are in data mode and the entire message consists
      # solely of a period on a line by itself then we
      # are being told to exit data mode
      if((Thread.current[:data_mode]) && (line.chomp =~ /^\.$/))
        Thread.current[:message][:data] += line
        Thread.current[:data_mode] = false

        Thread.current[:message][:data].gsub!(/\r\n\Z/, '').gsub!(/\.\Z/, '')
        new_message_event(Thread.current[:message])
        reset_message
        return "250 OK\r\n"
      end
      
      # If we are in date mode then we need to add
      # the new data to the message
      if(Thread.current[:data_mode])
        Thread.current[:message][:data] += line
        return ""
      else
        # If we somehow get to this point then
        # we have encountered an error
        return "500 ERROR\r\n"
      end
    end

    private

      def process_ehlo
        "250 #{@my_domain}\r\n"
      end

      def process_quit
        Thread.current[:connection_active] = false
        ""
      end

      def process_mail_from(line)
        Thread.current[:message][:from] = line.gsub(/^MAIL FROM\:/, '').strip
        "250 Ok\r\n"
      end

      def process_rcpt_to(line)
        Thread.current[:message][:to] << line.gsub(/^RCPT TO\:/, '').strip
        "250 Ok\r\n"
      end

      def process_data
        Thread.current[:data_mode] = true
        "354 Enter message, ending with \".\" on a line by itself\r\n"
      end
  end
end