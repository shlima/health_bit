[![pipeline status](https://travis-ci.com/shlima/health_bit.svg?branch=master)](https://travis-ci.com/shlima/health_bit) 
[![gem version](https://badge.fury.io/rb/health_bit.svg)](https://rubygems.org/gems/health_bit)

# HealthBit

![](./doc/logo.png?sanitize=true)

This gem was inspired by the [health_check](https://github.com/ianheggie/health_check), but is simpler and more 
extensible and contains up to 95% less code.

Key differences:
* is a rack application (just a lambda function)
* can be used with rails, sinatra or any other rack application
* can add custom checks
* can add multiple endpoints with independent checks
* can use any rack middleware (such as http basic auth, IP whitelist)

## Toc

* [Installation](#installation)
* [Configuration](#configuration)
* [Add Checks](#add-checks)
* [Add a Route](#add-a-route)
* [Password Protection](#password-protection)
* [Multiple endpoints](#multiple-endpoints)

## Check Examples

* [Database check](#database-check)
* [Redis check](#redis-check)
* [Sidekiq check](#sidekiq-check)
* [Rails cache check](#rails-cache-check)
* [Elasticsearch check](#elasticsearch-check)
* [RabbitMQ check](#rabbitmq-check)
* [HTTP check](#http-check)
* [ClickHouse check](#clickhouse-check)

## Installation
    
Add this line to your application's Gemfile:

```ruby
gem 'health_bit'
```

## Configuration

```ruby
# config/initializers/health_bit.rb

HealthBit.configure do |c|
  # DEFAULT SETTINGS ARE SHOWN BELOW
  c.success_text = '%<count>d checks passed 🎉'
  c.headers = { 
    'Content-Type' => 'text/plain;charset=utf-8', 
    'Cache-Control' => 'private,max-age=0,must-revalidate,no-store' 
  }
  c.success_code = 200
  c.fail_code = 500
  c.show_backtrace = false

  c.add('Check name') do
    # Body check, should returns `true` 
    true
  end
end
```
        
## Add Checks

By default, the **gem does not contain any checks**, **you should add the 
necessary checks by yourself**. The check should return `false` or `nil` 
to be considered unsuccessful or throw an exception, any other 
values are considered satisfactory.

Example checks:

```ruby
## Successful checks
HealthBit.add('PostgreSQL') do
  ApplicationRecord.connection.select_value('SELECT 1') == 1
end

HealthBit.add('Custom') do
  true
end

## Failed checks
HealthBit.add('Database') do
  false
end

HealthBit.add('Docker service') do
  raise 'not responding'
end

# The Check can be added as an object responding to a call
# (to be able to test your check)
class Covid19Check 
  def self.call
    false 
  end
end

HealthBit.add('COVID-19 Checker', Covid19Check)
```

## Add a Route

Since the gem is a rack application, you must mount it to app's 
routes. Below is an example for the Rails.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  mount HealthBit.rack => '/health'
end
```

```bash
curl --verbose http://localhost:3000/health

< HTTP/1.1 200 OK
< Content-Type: text/plain;charset=utf-8
< Cache-Control: private,max-age=0,must-revalidate,no-store
< X-Request-Id: 59a796b9-29f7-4302-b1ff-5d0b06dd6637
< X-Runtime: 0.006007
< Vary: Origin
< Transfer-Encoding: chunked

4 checks passed 🎉
```

## Password Protection

Since the gem is a common rack application, you can add any rack
middleware to it. Below is an example with HTTP-auth for the Rails.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  HealthBit.rack.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username), Digest::SHA256.hexdigest('user')) & ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password), Digest::SHA256.hexdigest('password'))
  end
  
  mount HealthBit.rack => '/health'
end
```

## Database check

```ruby
HealthBit.add('Database') do
  ApplicationRecord.connection.select_value('SELECT 1') == 1
end
```

## Redis check

```ruby
HealthBit.add('Redis') do
  Redis.current.ping == 'PONG'
end
```

## Sidekiq check

```ruby
HealthBit.add('Sidekiq') do
  Sidekiq.redis(&:ping) == 'PONG'
end
```

## Rails cache check

```ruby
HealthBit.add('Rails cache') do
  Rails.cache.read('1').nil?
end
```

## Elasticsearch check

```ruby
HealthBit.add('Elasticsearch') do
  Elasticsearch::Client.new.ping
end
```

## RabbitMQ check

```ruby
HealthBit.add('RabbitMQ') do
  Bunny::Connection.connect(&:connection)
end
```

## HTTP check

```ruby
HealthBit.add('HTTP check') do
  Net::HTTP.new('www.example.com', 80).request_get('/').kind_of?(Net::HTTPSuccess)
end
```

## ClickHouse check

```ruby
HealthBit.add('ClickHouse') do
  ClickHouse.connection.ping
end
```

## Multiple endpoints

Sometimes you have to add several health check endpoints. Let's say 
you have to check the docker container health and the health 
of your application as a whole. Below is an example for the Rails.

```ruby
# config/initializers/health_bit.rb

DockerCheck = HealthBit.clone
AppCheck = HealthBit.clone

DockerCheck.add('Docker Health') do
  true
end

AppCheck.add('App Health') do
  ApplicationRecord.connection.select_value("SELECT 't'::boolean")
end
```

```ruby
# config/routes.rb

Rails.application.routes.draw do
  mount DockerCheck.rack => '/docker'
  mount AppCheck.rack => '/app'
end
```
