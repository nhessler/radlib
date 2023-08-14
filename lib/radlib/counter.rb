module Radlib
  class Counter < Ractor
    private_class_method :new

    def self.inc(counter, num)
      counter.send([:inc, num])
    end

    def self.dec(counter, num)
      counter.send([:dec, num])
    end

    def self.get(counter)
      counter.send(:get)
      message = receive_if{|msg| msg.first == counter}
      message.last
    end
    
    def self.start(start_count = 0)
      new(start_count) do |count|

        setup(count)
        
        loop do
          case Ractor.receive
          in :inc, by
            do_inc(by)
          in :dec, by
            do_dec(by)
          in :get, asker
            parsel = do_get()
            asker.send([Ractor.current, parsel])
          in msg
            "unknown message '#{msg}' was received"
          end
        end
      end
    end

    def inc(by = 1)
      self.send([:inc, by])
    end

    def dec(by = 1)
      self.send([:dec, by])
    end

    def get()
      asker = Ractor.current
      self.send([:get, asker])
      message = Ractor.receive_if{ |msg| msg.first == self }
      message.last
    end

    private

    def setup(count)
      self[:count] = count
    end
    
    def do_inc(by)
      self[:count] = self[:count] + by
    end

    def do_dec(by)
      self[:count] = self[:count] - by
    end

    def do_get()
      self[:count]
    end
  end
end
