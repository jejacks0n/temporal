class ApplicationController < ActionController::Base

  def welcome
    render text: "Welcome, your time zone is: #{Time.zone}", layout: 'application'
  end

end
