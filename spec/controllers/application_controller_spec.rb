require 'spec_helper'

describe ApplicationController, type: :controller do

  before do
    Rails.application.config.time_zone = 'Central Time (US & Canada)'
  end

  it "set the timezone to the configured default if the cookie isn't set" do
    get :welcome
    Time.zone.to_s.should =~ /Central Time/
    response.code.should == "200"
  end

  it "set the timezone based on the cookie" do
    @request.cookies[:timezone] = 'America/Denver'
    get :welcome
    Time.zone.to_s.should =~ /Denver/
    response.code.should == "200"
  end

end
