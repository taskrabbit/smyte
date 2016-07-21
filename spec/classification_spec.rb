require 'spec_helper'

describe 'classification' do
  let(:classification) { Smyte::Classification.new(response) }

  context "block response" do
    let(:response) { JSON.parse(block_body) }

    it "should say to block" do
      classification.action.should == :block
    end

    it "should give grouped labels" do
      hash = classification.label_actions
      hash[:block].size.should == 1
      hash[:review].size.should == 1
      hash[:allow].size.should == 0
      hash[:unknown].size.should == 0
      hash[:weird].size.should == 0

      hash[:block].first.name.should == "cc_country_mismatch"
      hash[:review].first.name.should == "exp:high_fail_rate_payment"
    end

    it "should give label names to report" do
      classification.label_report.should == ["exp:high_fail_rate_payment", "cc_country_mismatch"]
    end

    it "should filter the response to a partial exp label" do
      classification = Smyte::Classification.new(response, {labels: ["high_fail_rate_payment"]})
      classification.action.should == :review
      classification.label_report.should == ["exp:high_fail_rate_payment"]
      hash = classification.label_actions
      hash[:block].size.should == 0
      hash[:review].size.should == 1
    end

    it "should filter the response to a full exp label" do
      classification = Smyte::Classification.new(response, {labels: ["exp:high_fail_rate_payment"]})
      classification.action.should == :review
      classification.label_report.should == ["exp:high_fail_rate_payment"]
      hash = classification.label_actions
      hash[:block].size.should == 0
      hash[:review].size.should == 1
    end

    it "should filter responses based on a regex" do
      classification = Smyte::Classification.new(response, {labels: [/something/,/mis/,"else"]})
      classification.action.should == :block
      classification.label_report.should == ["cc_country_mismatch"]
      hash = classification.label_actions
      hash[:block].size.should == 1
      hash[:review].size.should == 0
    end
  end

  context "review response" do
    let(:response) { JSON.parse(review_body) }

    it "should say to review" do
      classification.action.should == :review
    end

    it "should give grouped labels" do
      hash = classification.label_actions
      hash[:block].size.should == 0
      hash[:review].size.should == 2
      hash[:allow].size.should == 0
      hash[:unknown].size.should == 0
      hash[:weird].size.should == 0

      hash[:review].last.name.should == "cc_country_mismatch"
      hash[:review].first.name.should == "exp:high_fail_rate_payment"
    end

    it "should give label names to report" do
      classification.label_report.should == ["exp:high_fail_rate_payment", "cc_country_mismatch"]
    end
  end

  context "allow response" do
    let(:response) { JSON.parse(allow_body) }

    it "should say to allow" do
      classification.action.should == :allow
    end

    it "should give grouped labels" do
      hash = classification.label_actions
      hash[:block].size.should == 0
      hash[:review].size.should == 0
      hash[:allow].size.should == 0
      hash[:unknown].size.should == 0
      hash[:weird].size.should == 0
    end

    it "should give label names to report" do
      classification.label_report.should == []
    end
  end

  context "allow response with labels" do
    let(:response) { JSON.parse(allow_body_labels) }

    it "should say to allow" do
      classification.action.should == :allow
    end

    it "should give grouped labels" do
      hash = classification.label_actions
      hash[:block].size.should == 0
      hash[:review].size.should == 0
      hash[:allow].size.should == 2
      hash[:unknown].size.should == 0
      hash[:weird].size.should == 0

      hash[:allow].last.name.should == "cc_country_mismatch"
      hash[:allow].first.name.should == "exp:high_fail_rate_payment"
    end

    it "should give label names to report" do
      classification.label_report.should == []
    end
  end

  let(:allow_body_labels) { <<-BODY_JSON
    {
      "statusCode": 200,
      "message": "Action should be blocked.",
      "verdict": "ALLOW",
      "labels": {
        "exp:high_fail_rate_payment": {
          "rules": {
            "TwoOrMoreFailedPayments_IpHour": {
              "ruleFeatures": {
                "NumFailures": 2
              },
              "ruleDescription": "IP has 2 failed payments in the last hour."
            },        
            "TwoOrMoreFailedPayments_ActorHour": {
              "ruleFeatures": {
                "NumFailures": 2
              },
              "ruleDescription": "Actor has 2 failed payments in the last hour."
            }
          },
          "enabled": false,
          "verdict": "ALLOW"
        },
        "cc_country_mismatch": {
          "rules": {
            "CcShippingCountryMismatchTwoOrMoreUniqueCc_ActorDay": {
              "ruleFeatures": {
                "numCreditCardsLastDay": 2,
                "creditCardCountry": "US",
                "shippingCountry": "GB"
              },
              "ruleDescription": "Actor has used 2 unique credit cards in the last day and the credit card country: US doesn't match the shipping country: GB"
            },
            "CcShippingCountryMismatchTwoOrMoreFailedPayments_ActorDay": {
              "ruleFeatures": {
                "NumCreditCardsLastDay": 2,
                "CreditCardCountry": "US",
                "ShippingCountry": "GB"
              },
              "ruleDescription": "Actor has 2 failed payments in the last day and the credit card country: US doesn't match the shipping country: GB"
            }
          },
          "enabled": false,
          "verdict": "ALLOW"
        }
      }
    }
BODY_JSON
  }

  let(:allow_body) { <<-BODY_JSON
    {
      "statusCode": 200,
      "message": "Action should be blocked.",
      "verdict": "ALLOW",
      "labels": {}
    }
BODY_JSON
  }


  let(:review_body) { <<-BODY_JSON
    {
      "statusCode": 200,
      "message": "Action should be blocked.",
      "verdict": "BLOCK",
      "labels": {
        "exp:high_fail_rate_payment": {
          "rules": {
            "TwoOrMoreFailedPayments_IpHour": {
              "ruleFeatures": {
                "NumFailures": 2
              },
              "ruleDescription": "IP has 2 failed payments in the last hour."
            },        
            "TwoOrMoreFailedPayments_ActorHour": {
              "ruleFeatures": {
                "NumFailures": 2
              },
              "ruleDescription": "Actor has 2 failed payments in the last hour."
            }
          },
          "enabled": false,
          "verdict": "BLOCK"
        },
        "cc_country_mismatch": {
          "rules": {
            "CcShippingCountryMismatchTwoOrMoreUniqueCc_ActorDay": {
              "ruleFeatures": {
                "numCreditCardsLastDay": 2,
                "creditCardCountry": "US",
                "shippingCountry": "GB"
              },
              "ruleDescription": "Actor has used 2 unique credit cards in the last day and the credit card country: US doesn't match the shipping country: GB"
            },
            "CcShippingCountryMismatchTwoOrMoreFailedPayments_ActorDay": {
              "ruleFeatures": {
                "NumCreditCardsLastDay": 2,
                "CreditCardCountry": "US",
                "ShippingCountry": "GB"
              },
              "ruleDescription": "Actor has 2 failed payments in the last day and the credit card country: US doesn't match the shipping country: GB"
            }
          },
          "enabled": false,
          "verdict": "BLOCK"
        }
      }
    }
BODY_JSON
  }

  let(:block_body) { <<-BODY_JSON
    {
      "statusCode": 200,
      "message": "Action should be blocked.",
      "verdict": "BLOCK",
      "labels": {
        "exp:high_fail_rate_payment": {
          "rules": {
            "TwoOrMoreFailedPayments_IpHour": {
              "ruleFeatures": {
                "NumFailures": 2
              },
              "ruleDescription": "IP has 2 failed payments in the last hour."
            },        
            "TwoOrMoreFailedPayments_ActorHour": {
              "ruleFeatures": {
                "NumFailures": 2
              },
              "ruleDescription": "Actor has 2 failed payments in the last hour."
            }
          },
          "enabled": false,
          "verdict": "BLOCK"
        },
        "cc_country_mismatch": {
          "rules": {
            "CcShippingCountryMismatchTwoOrMoreUniqueCc_ActorDay": {
              "ruleFeatures": {
                "numCreditCardsLastDay": 2,
                "creditCardCountry": "US",
                "shippingCountry": "GB"
              },
              "ruleDescription": "Actor has used 2 unique credit cards in the last day and the credit card country: US doesn't match the shipping country: GB"
            },
            "CcShippingCountryMismatchTwoOrMoreFailedPayments_ActorDay": {
              "ruleFeatures": {
                "NumCreditCardsLastDay": 2,
                "CreditCardCountry": "US",
                "ShippingCountry": "GB"
              },
              "ruleDescription": "Actor has 2 failed payments in the last day and the credit card country: US doesn't match the shipping country: GB"
            }
          },
          "enabled": true,
          "verdict": "BLOCK"
        }
      }
    }
BODY_JSON
  }

end