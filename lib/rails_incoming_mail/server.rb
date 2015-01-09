require "gserver"

module RailsIncomingMail
  
  class Server
    
    def initialize
      @responder = RailsIncomingMail::Responder.new
    end


    def process_line(line)
      @responder.process_line(line)
    end
  end
end
