require 'temporal/controller_additions'

module Temporal
  class Engine < ::Rails::Engine
    initializer "temporal.controller_additions" do
      ActiveSupport.on_load(:action_controller) do
        include Temporal::ControllerAdditions
      end
    end
  end
end
