# Vidocq

As you know, a gem isn't cool without an obscure name. Which is why Vidocq gets its name from the first known private investigator, [Eugène
François
Vidocq](http://en.wikipedia.org/wiki/Eug%C3%A8ne_Fran%C3%A7ois_Vidocq).
Vidocq is a library for hunting down service instances. Services that
register as running using an ephemeral zookeeper znode can be discovered
with Vidocq.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'vidocq'
```

And then execute:

    $ bundle

Or install it yourself as:
    $ gem install vidocq

## Usage
```ruby
require 'vidocq'
v = Vidocq.new('myzkserver:2181')
response = v.call(:service_id => 'my-service', :version => '0.1', :id => '42')
```

..or, if you want a faster version that doesn't bother ZooKeeper all the time:
```ruby
v = Vidocq.cached('myservice','0.1','myzkserver:2181')
response = v.call(:id => '42')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
