module Temporal
  module ControllerAdditions
    def self.included(base)
      base.send(:before_filter, :set_time_zone)
    end

    def set_time_zone
      Time.zone = ActiveSupport::TimeZone.new(cookies[:timezone]) || Rails.application.config.time_zone
    end
  end
end
