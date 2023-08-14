module Radlib
  module TCP
    class Client < Ractor
      private_class_method :new
      def self.async(id, server_address, server_port, server_requests = 1)
        server_params = {address: server_address, port: server_port, requests: server_requests}
        new(server_params, name: "client-#{id}") do |params|
          params[:requests].times do |i|
            server = TCPSocket.open(params[:address], params[:port])
            
            request = "HELLO from #{self.name}"
            server.puts(request)

            response = server.gets

            puts "#{Time.now} - Request #{i}: #{response.strip}"
            
            server.close
          end
        end
      end
    end
  end
end
