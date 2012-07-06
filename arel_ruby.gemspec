# -*- encoding: utf-8 -*-
require File.expand_path('../lib/arel_ruby/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Akira Matsuda"]
  gem.email         = ["ronnie@dio.jp"]
  gem.description   = 'ARel Ruby visitor'
  gem.summary       = 'ARel Ruby visitor'
  gem.homepage      = 'https://github.com/amatsuda/arel_ruby'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "arel_ruby"
  gem.require_paths = ["lib"]
  gem.version       = ArelRuby::VERSION
end
