require 'spec_helper'

describe 'notification' do
  let(:notification) { Smyte::Notification.new(response) }

  describe ".parse" do
    let(:response) { JSON.parse(blocked_body) }

    it "takes in webhook secret and response" do
      Smyte.webhook_secret = "hook"
      notification = Smyte::Notification.parse("hook", response)
      notification.items.first.action.should == :block
    end

    it "should raise if the webhook doesn't work" do
      lambda {
        Smyte.webhook_secret = "hook"
        Smyte::Notification.parse("other", response)
      }.should raise_error("invalid webhook_secret: other")
    end
  end

  context "block response" do
    let(:response) { JSON.parse(blocked_body) }

    it "should give grouped actions by object" do
      objects = notification.items
      objects.size.should == 2

      obj = objects.first
      obj.key.should == 'user/1234'
      obj.type.should == 'user'
      obj.id.should == '1234'
      obj.action.should == :block
      obj.label_report.should == ["bad_user", "exp:review_user"]

      hash = obj.label_actions
      hash[:block].size.should == 1
      hash[:review].size.should == 1
      hash[:allow].size.should == 0
      hash[:unknown].size.should == 0
      hash[:weird].size.should == 0

      hash[:block].first.name.should == "bad_user"
      hash[:review].first.name.should == "exp:review_user"

      obj = objects.last
      obj.key.should == 'user/6789'
      obj.type.should == 'user'
      obj.id.should == '6789'
      obj.action.should == :block
      obj.label_report.should == ["bad_user"]

      hash = obj.label_actions
      hash[:block].size.should == 1
      hash[:review].size.should == 0
      hash[:allow].size.should == 0
      hash[:unknown].size.should == 0
      hash[:weird].size.should == 0

      hash[:block].first.name.should == "bad_user"
    end
  end

  context "pending response" do
    let(:response) { JSON.parse(review_body) }

    it "should give grouped actions by object" do
      objects = notification.items
      objects.size.should == 1

      obj = objects.first
      obj.key.should == 'user/1234'
      obj.type.should == 'user'
      obj.id.should == '1234'
      obj.action.should == :review
      obj.label_report.should == ["exp:bad_user", "exp:review_user"]

      hash = obj.label_actions
      hash[:block].size.should == 0
      hash[:review].size.should == 2
      hash[:allow].size.should == 0
      hash[:unknown].size.should == 0
      hash[:weird].size.should == 0

      hash[:review].first.name.should == "exp:bad_user"
      hash[:review].last.name.should == "exp:review_user"
    end
  end


  let(:review_body) { <<-BODY_JSON
    {
      "items": [
        {
          "item": "user/1234",
          "labelType": "PENDING",
          "labelName": "exp:bad_user",
          "timestamp": "2016-02-12T17:58:39.560Z",
          "reasons": {
            "YoureACrookCaptainHook": "user/1234 was not practicign proper maritime law.",
            "manuallyAdded": false
          },
          "smyteAdminUrl": "https://taskrabbit.smyte.com/admin/lists2/bad_user/all/Object/user%2F1234",
          "additionalFeatures": [
            "Optional: additional webhook information if configured. If not this key is omitted."
          ]
        },
        {
          "item": "user/1234",
          "labelType": "PENDING",
          "labelName": "exp:review_user",
          "timestamp": "2016-02-12T17:58:39.560Z",
          "reasons": {
            "YoureACrookCaptainHook": "user/1234 was not practicign proper maritime law.",
            "manuallyAdded": false
          },
          "smyteAdminUrl": "https://taskrabbit.smyte.com/admin/lists2/bad_user/all/Object/user%2F1234",
          "additionalFeatures": [
            "Optional: additional webhook information if configured. If not this key is omitted."
          ]
        }
      ]
    }
BODY_JSON
  }

  let(:blocked_body) { <<-BODY_JSON
    {
      "items": [
        {
          "item": "user/1234",
          "labelType": "ADDED",
          "labelName": "bad_user",
          "timestamp": "2016-02-12T17:58:39.560Z",
          "reasons": {
            "YoureACrookCaptainHook": "user/1234 was not practicign proper maritime law.",
            "manuallyAdded": false
          },
          "smyteAdminUrl": "https://taskrabbit.smyte.com/admin/lists2/bad_user/all/Object/user%2F1234",
          "additionalFeatures": [
            "Optional: additional webhook information if configured. If not this key is omitted."
          ]
        },
        {
          "item": "user/6789",
          "labelType": "ADDED",
          "labelName": "bad_user",
          "timestamp": "2016-02-12T17:58:39.560Z",
          "reasons": {
            "YoureACrookCaptainHook": "user/6789 was not practicign proper maritime law.",
            "manuallyAdded": false
          },
          "smyteAdminUrl": "https://taskrabbit.smyte.com/admin/lists2/bad_user/all/Object/user%2F1234",
          "additionalFeatures": [
            "Optional: additional webhook information if configured. If not this key is omitted."
          ]
        },
        {
          "item": "user/1234",
          "labelType": "PENDING",
          "labelName": "exp:review_user",
          "timestamp": "2016-02-12T17:58:39.560Z",
          "reasons": {
            "YoureACrookCaptainHook": "user/1234 was not practicign proper maritime law.",
            "manuallyAdded": false
          },
          "smyteAdminUrl": "https://taskrabbit.smyte.com/admin/lists2/bad_user/all/Object/user%2F1234",
          "additionalFeatures": [
            "Optional: additional webhook information if configured. If not this key is omitted."
          ]
        }
      ]
    }
BODY_JSON
  }

end