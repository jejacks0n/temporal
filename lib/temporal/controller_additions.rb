module Temporal
  module ControllerAdditions
    def self.included(base)
      if Rails::VERSION::MAJOR >= 5
        base.send(:before_action, :set_time_zone)
      else
        base.send(:before_filter, :set_time_zone)
      end
    end

    def set_time_zone
      Time.zone = cookies[:timezone] ? ActiveSupport::TimeZone.new(cookies[:timezone]) : Rails.application.config.time_zone
    end
  end
end
