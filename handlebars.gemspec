# -*- encoding: utf-8 -*-
require File.expand_path("../lib/handlebars/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "handlebars"
  s.version     = Handlebars::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Martin Schuerrer']
  s.email       = ['martin@schuerrer.org']
  s.homepage    = "http://github.com/MSch/handlebars-ruby"
  s.summary     = "handlebars.js port to ruby"
  s.description = "A straight port of handlebars.js to ruby. Currently unfinished, if you've got a complete version let me know so I'll release the name to you"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "handlebars"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 2.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
