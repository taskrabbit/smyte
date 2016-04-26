# Smyte

[Smyte](https://www.smyte.com) is a fraud-checking service. This gem makes it a bit easier to work with their [API](https://docs.smyte.com/).

## Setup

`gem install smyte`

```ruby
require 'smyte'

Smyte.enabled    = true
Smyte.api_key    = '123456789'
Smyte.api_secret = 'qwertyuiopasdfghjkl'
Smyte.webhook_secret = 'zxcvbnmpoiuytrewq'
```

## Sending data to Smyte

Uses this [API](https://docs.smyte.com/docs/sending-data-to-smyte).

```ruby
payload = {
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
  timestamp: Time.now
}

Smyte.action('my_event', payload)

```

## Receiving classification results

Uses this [API](https://docs.smyte.com/docs/receiving-classification-results).

```ruby
# payload same as before (or other, of course)
classification = Smyte.classify('my_event', payload)

puts classification.action # will be :block, :review, or :allow
puts classification.label_report # for example on block ["exp:high_fail_rate_payment", "cc_country_mismatch"]

```

## Webhooks

Uses this [API](https://docs.smyte.com/docs/webhooks).
Smyte does a POST to your endpoint

```ruby
# for example in a Rails controller action
secret = request.headers["X-Smyte-Signature"]
notification = ::Smyte.webhook(secret, params)
notification.items.each do |item|
  puts item.action # will be :block, :review, or :allow
  puts item.type # for example "user"
  puts item.id   # user id
  puts item.label_report #  for example on block  ["bad_user"]
end

```


