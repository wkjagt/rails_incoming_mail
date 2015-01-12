require "observer"

module RailsIncomingMail

  class Transaction
    
    include Observable

    attr_accessor :message, :data_mode, :mail_from, :rcpt_to

    def initialize(my_domain)
      @my_domain = my_domain
      @message = ""
      @rcpt_to = []
      @mail_from = ""
      @data_mode = false
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

    private

      def line(data)
        "#{data}\r\n"
      end

      def process_ehlo_line
        line "250 #{@my_domain}"
      end

      def process_quit_line
        raise Quit
      end

      def process_mail_from_line(line)
        @mail_from = line.gsub(/^MAIL FROM\:/, '').strip
        line "250 Ok"
      end

      def process_rcpt_to_line(line)
        @rcpt_to << line.gsub(/^RCPT TO\:/, '').strip
        line "250 Ok"
      end

      def process_data_line
        @data_mode = true
        line "354 Enter message, ending with \".\" on a line by itself"
      end

      def process_data(line)
        raise ProtocolError unless @data_mode

        # a dot on a line means end of message
        unless line.chomp == "."
          @message += line
          return ""
        end

        completed          
      end

      def completed
        changed
        notify_observers(:completed)

        @data_mode = false
        line "250 Ok"
      end
  end
end