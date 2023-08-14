# frozen_string_literal: true

require_relative "radlib/version"

require_relative "radlib/agent"
require_relative "radlib/counter"
require_relative "radlib/tarai"
require_relative "radlib/t_c_p"

module Radlib
  class Error < StandardError; end

#   actor "Agent" do |a|

#     a.setup do
#       0
#     end
    
#     a.tell :set, state, move: true do
#       state = state 
#     end

#     a.ask :get do
      
#     end
#   end
end
