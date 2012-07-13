module ActiveRecord
  Relation.class_eval do
    def exec_queries_in_ruby
      return @records if loaded?
      ruby = build_arel.to_ruby
      connection.send(:log, ruby.to_source, 'RUBY') do
        ruby.call self.klass.all
      end
    end
  end
end
