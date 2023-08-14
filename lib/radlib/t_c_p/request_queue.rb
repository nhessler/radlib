module Radlib
  module TCP
    class RequestQueue < Ractor
      private_class_method :new

      def self.start(worker_count = 4)
        new(worker_count) do |count|
          setup(count)

          loop do
            case Ractor.receive
            in [:process, client]
              do_process(client)
            in [:ready, worker]
              do_ready(worker)
            in message
              puts "Unknown Message: '#{message}' was received"
            end
          end
        end
      end

      def process(client)
        self.send([:process, client], move: true)
      end

      def ready(worker)
        self.send([:ready, worker])
      end

      private

      def setup(count)
        self[:workers] = count.times.map do |i|
          ractor = RequestWorker.start(Ractor.current, i)
          {id: i, ractor: ractor, ready: true}
        end

        self[:clients] = []
      end

      def workers
        self[:workers]
      end

      def clients
        self[:clients]
      end

      def do_process(client)
        clients.append(client)
        delegate_work
      end

      def do_ready(ractor)
        worker = workers.find{|w| w[:ractor] == ractor}
        worker[:ready] = true
        delegate_work
      end

      def delegate_work
        while any_clients? and any_workers?
          worker = workers.find{|w| w[:ready] }
          client = clients.shift
          worker[:ractor].work(client)
          worker[:ready] = false
        end
      end

      def any_workers?
        workers.any?{|w| w[:ready]}
      end
      
      def any_clients?
        not clients.empty?
      end
    end
  end
end
