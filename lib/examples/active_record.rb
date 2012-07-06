module ActiveRecord
  Relation.class_eval do
    def exec_queries_in_ruby
      return @records if loaded?
      ruby = build_arel.to_ruby
      connection.send(:log, ruby, 'RUBY') do
        self.klass.all.instance_eval ruby
      end
    end
  end
end
