require 'spec_helper'

describe "client" do
  let(:options) { { api_key: "key", api_secret: "secret" } }
  let(:client)  { Smyte::Client.new(options) }

  let(:timestamp) { "2015-01-22T09:14:12-08:00" }
  let(:payload) {{
    data: {
      custom_id: 1
    },
    http_request: {
      headers: {
        "X-Real-IP" => "5.6.7.8"
      },
      path: "/login"
    },
    session: {
      id: 'sessionguid',
      action: {
        user_id: 2
      }
    },
    timestamp: timestamp
  }}

  describe "#initialize" do
    it "uses given keys and such with defaults" do
      client.api_key.should == options[:api_key]
      client.api_secret.should == options[:api_secret]
      client.enabled.should == true
    end

    it "freaks out if no api stuff" do
      lambda {
        Smyte::Client.new(api_secret: nil)
      }.should raise_error("Smyte api_key not set")
    end

    it "passes through being disbaled" do
      client = Smyte::Client.new(options.merge(enabled: false))
      client.enabled.should == false
    end
  end

  describe ".action" do
    it "should send it" do
      VCR.use_cassette("action_simple", record: :none) do
        response = client.action('my_event', payload)
        response.should == true
      end
    end

    it "should return true when disabled" do
      client = Smyte::Client.new(options.merge(enabled: false))
      response = client.action('my_event', payload)
      response.should == true
    end
  end

  describe ".classify" do
    it "should send it" do
      VCR.use_cassette("classify_simple", record: :none) do
        response = client.classify('my_event', payload)
        response.action.should == :allow
      end
    end

    it "should report things to block" do
      VCR.use_cassette("classify_block", record: :none) do
        response = client.classify('my_event', payload)
        response.action.should == :block
      end
    end

    it "should allow when disabled" do
      client = Smyte::Client.new(options.merge(enabled: false))
      response = client.classify('my_event', payload)
      response.action.should == :allow
    end
  end


  describe "Integration" do
    before do
      Smyte.api_key = "key"
      Smyte.api_secret = "secret"
    end

    it "should classify through core class" do
      VCR.use_cassette("classify_simple", record: :none) do
        response = Smyte.classify('my_event', payload)
        response.action.should == :allow
      end
    end

    it "should send action through core class" do
      VCR.use_cassette("action_simple", record: :none) do
        response = Smyte.action('my_event', payload)
        response.should == true
      end
    end
  end

end