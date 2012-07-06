require 'arel_ruby/version'
require 'arel/visitors/ruby'

module Arel
  # for AR <= 3.2.6 compatibility
  module Relation
  end

  class TreeManager
    def to_ruby
      Visitors::Ruby.new.accept @ast
    end
  end
end
