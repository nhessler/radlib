module Radlib
  module Tarai
    class SeqTarai
      def call (x, y, z)
        if x <= y
          y
        else
          call(
            call(x - 1, y, z),
            call(y - 1, z, x),
            call(z - 1, x, y))
        end
      end
    end
    
    class ParTarai < Ractor
      private_class_method :new
      
      def self.async(start_x, start_y, start_z)
        new(start_x, start_y, start_z) do |x, y, z|
          result = call(x, y, z)
          
          loop do
            case Ractor.receive
            in :await, asker
              asker.send([self, result])
              break
            in message
              puts "Unknown Message: '#{message}' was received"
            end
          end
        end
      end
      
      def await()
        self.send([:await, Ractor.current])
        message = Ractor.receive_if{|msg| msg.first == self}
        message.last
      end

      private
      
      def call(x, y, z)
        if x <= y
          y
        else
          call(
            call(x - 1, y, z),
            call(y - 1, z, x),
            call(z - 1, x, y))
        end
      end
    end

    class RecTarai < Ractor
      private_class_method :new

      def self.async(start_x, start_y, start_z)
        new(start_x, start_y, start_z) do |x, y, z|
          result = call(x, y, z)
          
          loop do
            case Ractor.receive
            in :await, asker
              asker.send([self, result])
              break
            in message
              puts "Unknown Message: '#{message}' was received"
            end
          end
        end
      end
      
      def await()
        self.send([:await, Ractor.current])
        message = Ractor.receive_if{|msg| msg.first == self}
        message.last
      end

      private
      
      def call(x, y, z)
        if x <= y
          y
        else
          rtx = RecTarai.async(x - 1, y, z)
          rty = RecTarai.async(y - 1, z, x)
          rtz = RecTarai.async(z - 1, x, y)

          new_x = rtx.await
          new_y = rty.await
          new_z = rtz.await

          rtt = RecTarai.async(new_x, new_y, new_z)

          rtt.await
        end
      end
    end
  end
end
