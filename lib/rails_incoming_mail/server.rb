require "gserver"

module RailsIncomingMail
  
  class Server < GServer

    def initialize(domain, port = 25, host = "127.0.0.1", max_connections = 4, *args)
      super(port, host, max_connections, *args)
      @domain = domain
    end

    def serve(io)
      setup_transaction(io)
      receive(io)
    rescue Quit
    ensure
      reset_transaction(io)
    end

    private
      def transaction
        Thread.current[:incoming_mail_transaction]
      end

      def setup_transaction(io)
        transaction = RailsIncomingMail::Transaction.new(@domain)
        transaction.add_observer(self)
        Thread.current[:incoming_mail_transaction] = transaction
        io.print "220 hello\r\n"
      end

      def reset_transaction(io)
        Thread.current[:incoming_mail_transaction] = nil
        io.print "221 bye\r\n"
        io.close
      end

      def receive(io)
        loop do
          if IO.select([io], nil, nil, 0.1)
            process_line(io.readpartial(4096))
          end
          break if io.closed?
        end
      end

      def process_line
        output = transaction.process_line(line)
        io.print(output) unless output.empty?
      end
  end
end
