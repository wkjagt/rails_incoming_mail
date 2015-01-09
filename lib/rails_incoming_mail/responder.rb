module RailsIncomingMail
  class Responder

    def initialize(my_domain)
      Thread.current[:message] = {}
      Thread.current[:message][:to] = []
      Thread.current[:data_mode] = false
      Thread.current[:message][:data] = ""
      @my_domain = my_domain
    end

    def process_line(line)
      return case line
             when (/^(HELO|EHLO)/);  process_ehlo_line
             when (/^QUIT/);         process_quit_line
             when (/^MAIL FROM\:/);  process_mail_from_line(line)
             when (/^RCPT TO\:/);    process_rcpt_to_line(line)
             when (/^DATA/);         process_data_line
             else;                   process_data(line)
      end
    end

    def message
      Thread.current[:message]
    end

    def data_mode?
      Thread.current[:data_mode]
    end

    private

      def process_ehlo_line
        "250 #{@my_domain}\r\n"
      end

      def process_quit_line
        Thread.current[:connection_active] = false
        ""
      end

      def process_mail_from_line(line)
        Thread.current[:message][:from] = line.gsub(/^MAIL FROM\:/, '').strip
        "250 Ok\r\n"
      end

      def process_rcpt_to_line(line)
        Thread.current[:message][:to] << line.gsub(/^RCPT TO\:/, '').strip
        "250 Ok\r\n"
      end

      def process_data_line
        Thread.current[:data_mode] = true
        "354 Enter message, ending with \".\" on a line by itself\r\n"
      end

      def process_data(line)
        # If we are in data mode and the entire message consists
        # solely of a period on a line by itself then we
        # are being told to exit data mode
        if((Thread.current[:data_mode]) && (line.chomp =~ /^\.$/))
          Thread.current[:message][:data] += line
          Thread.current[:data_mode] = false

          # Thread.current[:message][:data].gsub!(/\r\n\Z/, '').gsub!(/\.\Z/, '')
          # new_message_event(Thread.current[:message])
          # reset_message
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
  end
end