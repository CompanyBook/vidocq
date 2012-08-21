# Vidocq

As you know, a gem isn't cool without an obscure name. Which is why Vidocq gets its name from the first known private investigator, [Eugène
François
Vidocq](http://en.wikipedia.org/wiki/Eug%C3%A8ne_Fran%C3%A7ois_Vidocq).
Vidocq is a library for hunting down service instances. Services that
register as running using an ephemeral zookeeper znode can be discovered
with Vidocq.

## Installation

Add this line to your application's Gemfile:

    gem 'vidocq'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vidocq

## Usage

    require 'vidocq'
    v = Vidocq.new('localhost:2181')
    url = v.get_endpoint('finance-service','0.1')
    # perform request to url...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
