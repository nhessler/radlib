module Radlib
  class Agent < Ractor
    private_class_method :new
    
    def self.start(start_state)
      new(start_state) do |state|

        setup(state)
        
        loop do
          case Ractor.receive
          in :set, new_state
            do_set(new_state)
          in :get, asker
            parsel = do_get()
            asker.send([Ractor.current, parsel])
          in message
            puts "Unknown Message: '#{message}' was received"
          end
        end
      end
    end

    def set(new_state)
      self.send([:set, new_state])
    end

    def get()
      asker = Ractor.current
      self.send([:get, asker])
      message = Ractor.receive_if{|msg| msg.first == self}
      message.last
    end
    
    private

    def setup(state)
      self[:state] = state
    end
    
    def do_set(new_state)
      self[:state] = new_state
    end

    def do_get()
      self[:state]
    end
  end
end
