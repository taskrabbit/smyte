require 'spec_helper'

describe "config" do
  let (:config) { Smyte::Config.new }
  describe "setters" do
    it "gets and sets logger" do
      config.logger.should == nil
      config.logger = "log"
      config.logger.should == "log"
    end
  end


  describe "API keys" do
    it "should freak out if not set" do
      lambda{
        config.api_key
      }.should raise_error("Smyte api_key not set")

      lambda{
        config.api_secret
      }.should raise_error("Smyte api_secret not set")

      lambda{
        config.webhook_secret
      }.should raise_error("Smyte webhook_secret not set")
    end

    it "should use the one set" do
      config.api_key = "a"
      config.api_secret = "c"
      config.webhook_secret = "d"

      config.api_key.should == "a"
      config.api_secret.should == "c"
      config.webhook_secret.should == "d"
    end
  end

  describe "Enablement" do
    it "should default to true" do
      config.enabled.should == true
      config.enabled?.should == true
    end

    it "should be able to be set to boolean" do
      config.enabled = false
      config.enabled.should == false

      config.enabled = true
      config.enabled.should == true
    end

    it "should be able to be set to truthy stuff" do
      config.enabled = "false"
      config.enabled.should == false

      config.enabled = "true"
      config.enabled.should == true

      config.enabled = 0
      config.enabled.should == false

      config.enabled = 1
      config.enabled.should == true
    end
  end

  describe "Integration" do
    it "should connect through core class" do
      Smyte.api_key = "test"
      Smyte.api_key.should == "test"

      lambda{
        Smyte.api_secret
      }.should raise_error("Smyte api_secret not set")
      Smyte.api_secret = "secret"
      Smyte.api_secret.should == "secret"

      Smyte.webhook_secret = "hook"
      Smyte.webhook_secret.should == "hook"

      Smyte.logger.should == nil
      Smyte.logger = "log"
      Smyte.logger.should == "log"

      Smyte.enabled?.should == true
      Smyte.enabled.should == true
      Smyte.enabled = false
      Smyte.enabled?.should == false
    end
  end

end