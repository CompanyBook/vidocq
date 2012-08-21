# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vidocq/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alexander Mossin"]
  gem.email         = ["alexander@companybook.no"]
  gem.description   = %q{A library for discover service instances registered in ZooKeeper.}
  gem.summary       = %q{A library for discover service instances registered in ZooKeeper.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "vidocq"
  gem.require_paths = ["lib"]
  gem.version       = Vidocq::VERSION

  gem.add_dependency('zk', '>= 1.6.4')
end
