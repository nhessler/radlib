module Radlib
  module TCP
    class Server < Ractor
      private_class_method :new

      def self.start(server_port, queue_size = 4)
        new(server_port, queue_size) do |port, size|
          setup(port, size)

          take_requests()
        end
      end

      private
      
      def setup(port, size)
        self[:server] = TCPServer.new(port)
        self[:queue] = RequestQueue.start(size)
      end

      def take_requests()
        loop do
          request = self[:server].accept
          self[:queue].process(request)
        end
      end
    end
  end
end
