require 'spec_helper'

describe Temporal do

  it "is a module" do
    Temporal.should be_a(Module)
  end

  it "has a version" do
    Temporal::VERSION.should be_a(String)
  end

  it "defines ControllerAdditions" do
    Temporal::ControllerAdditions.should be_a(Module)
  end

  it "includes ControllerAdditions in ActionController::Base" do
    ActionController::Base.new.methods.should include(:set_time_zone)
  end

end
