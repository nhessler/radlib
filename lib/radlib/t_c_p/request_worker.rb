module Radlib
  module TCP
    class RequestWorker < Ractor
      private_class_method :new
      
      def self.start(worker_queue, id)
        new(worker_queue, name: "worker-#{id}") do |queue|
          loop do
            case Ractor.receive
            in :work, client
              do_work(client)
              queue.ready(Ractor.current)
            in message
              puts "Unknown Message; '#{message}' was received"
            end
          end
        end
      end

      def work(request)
        self.send([:work, request], move: true)
      end
      
      private

      def do_work(client)
        request = client.gets

        if result = request.match(/^HELLO from client-(.*?)$/)
          client_id = result[1]
          pause()
          response = "HEY, client-#{client_id}! I'm #{self.name}."

          client.puts(response)                                                         
        end                                                   

        client.close
      end

      def pause()
        secs = [1, 2, 3].sample
        sleep secs
      end
    end
  end
end
