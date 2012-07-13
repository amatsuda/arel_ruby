# ArelRuby

ARel Ruby visitor

## Installation

Add this line to your application's Gemfile:

    gem 'arel_ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arel_ruby

## Usage

This gem adds `to_ruby` method onto ARel.
The `to_ruby` method transforms ARel AST into pure Ruby Enumerable manipulations, so that you can execute queries without using any RDBMS engine.
Try this on your Rails app and you will realize what's actually gonna happen.

    YourActiveRecordModel.where(name: 'foo').to_ruby.to_source
    YourActiveRecordModel.order('id').to_ruby.to_source
    YourActiveRecordModel.offset(10).limit(5).to_ruby.to_source
    YourActiveRecordModel.group('created_at').to_ruby.to_source


## Examples

See examples directory

## Contributing

Fork and PR
