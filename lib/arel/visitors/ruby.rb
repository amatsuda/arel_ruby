require 'bigdecimal'
require 'date'

module Arel
  module Visitors
    class Ruby < Arel::Visitors::Visitor
      def initialize
        @connection = Object.new.extend(ActiveRecord::ConnectionAdapters::Quoting)
        @dummy_column = Struct.new(:type).new
      end

      private
#       def visit_Arel_Nodes_DeleteStatement o
#       end

#       def build_subselect key, o
#       end

#       def visit_Arel_Nodes_UpdateStatement o
#       end

#       def visit_Arel_Nodes_InsertStatement o
#       end

#       def visit_Arel_Nodes_Exists o
#       end

#       def visit_Arel_Nodes_True o
#       end

#       def visit_Arel_Nodes_False o
#       end

#       def visit_Arel_Nodes_Values o
#       end

      def visit_Arel_Nodes_SelectStatement o
        ProcWithSourceCollection.new([
            o.cores.map { |x| visit_Arel_Nodes_SelectCore x },
            (o.orders.map { |x| visit_Arel_Nodes_OrderCore x } unless o.orders.empty?),
            (visit(o.offset) if o.offset),
            (visit(o.limit) if o.limit),
            o.cores.map { |x| x.groups.map { |x| visit x} },
          ])
      end

      def visit_Arel_Nodes_SelectCore o
        [
#           ("#{o.projections.map { |x| visit x }.join ', '}" unless o.projections.empty?),
#           (visit(o.source) if o.source && !o.source.empty?),
          (o.wheres.map { |x| visit x } unless o.wheres.empty?)
#           (visit(o.having) if o.having),
        ]
    end

      def visit_Arel_Nodes_OrderCore order
        #FIXME order_by('a, b') shouldn't actaully be sort_by(&:a).sort_by(&:b)
        order.split(',').map(&:strip).map do |o|
          attr, direction = o.split(/\s+/)
          v = visit attr
          ProcWithSource.new("sort_by(&:#{v})#{'.reverse' if direction == 'desc'}") do |collection|
            col = collection.sort_by {|c| c.send v}
            col.reverse! if direction == 'desc'
            col
          end
        end
      end

#       def visit_Arel_Nodes_Bin o
#       end

#       def visit_Arel_Nodes_Distinct o
#       end

#       def visit_Arel_Nodes_DistinctOn o
#       end

#       def visit_Arel_Nodes_With o
#       end

#       def visit_Arel_Nodes_WithRecursive o
#       end

#       def visit_Arel_Nodes_Union o
#       end

#       def visit_Arel_Nodes_UnionAll o
#       end

#       def visit_Arel_Nodes_Intersect o
#       end

#       def visit_Arel_Nodes_Except o
#       end

#       def visit_Arel_Nodes_NamedWindow o
#       end

#       def visit_Arel_Nodes_Window o
#       end

#       def visit_Arel_Nodes_Rows o
#       end

#       def visit_Arel_Nodes_Range o
#       end

#       def visit_Arel_Nodes_Preceding o
#       end

#       def visit_Arel_Nodes_Following o
#       end

#       def visit_Arel_Nodes_CurrentRow o
#       end

#       def visit_Arel_Nodes_Over o
#       end

#       def visit_Arel_Nodes_Having o
#       end

      def visit_Arel_Nodes_Offset o
        v = visit o.expr
        ProcWithSource.new("from(#{v})") {|collection| collection.from(v) }
      end

      def visit_Arel_Nodes_Limit o
        v = visit o.expr
        ProcWithSource.new("take(#{v})") {|collection| collection.take(v) }
      end

      def visit_Arel_Nodes_Grouping o
        # doubtful implementation
        v = visit o.expr
        ProcWithSource.new("select {|g| g.#{v.to_source}}") { |collection| collection.select {|obj| v.call(obj) } }
      end

#       def visit_Arel_Nodes_Ascending o
#       end

#       def visit_Arel_Nodes_Descending o
#       end

      def visit_Arel_Nodes_Group o
        v = visit o.expr
        ProcWithSource.new("group_by {|g| g.#{v} }") {|collection| collection.group_by {|g| g.send v } }
      end

#       def visit_Arel_Nodes_NamedFunction o
#       end

#       def visit_Arel_Nodes_Extract o
#       end

#       def visit_Arel_Nodes_Count o
#       end

#       def visit_Arel_Nodes_Sum o
#       end

#       def visit_Arel_Nodes_Max o
#       end

#       def visit_Arel_Nodes_Min o
#       end

#       def visit_Arel_Nodes_Avg o
#       end

#       def visit_Arel_Nodes_TableAlias o
#       end

      def visit_Arel_Nodes_Between o
        l, r =  visit(o.left), Range.new(o.right.children.first, o.right.children.last)
        ProcWithSource.new("#{l}.in? #{r.inspect}") { |o| o.send(l).in?(r) }
      end

#       def visit_Arel_Nodes_GreaterThanOrEqual o
#       end

#       def visit_Arel_Nodes_GreaterThan o
#       end

#       def visit_Arel_Nodes_LessThanOrEqual o
#       end

#       def visit_Arel_Nodes_LessThan o
#       end

#       def visit_Arel_Nodes_Matches o
#       end

#       def visit_Arel_Nodes_DoesNotMatch o
#       end

      def visit_Arel_Nodes_JoinSource o
        # do nothing
      end

#       def visit_Arel_Nodes_StringJoin o
#       end

#       def visit_Arel_Nodes_OuterJoin o
#       end

#       def visit_Arel_Nodes_InnerJoin o
#       end

#       def visit_Arel_Nodes_On o
#       end

      def visit_Arel_Nodes_Not o
        case o.expr
        when Arel::Nodes::Between
          c = o.expr
          l, r =  visit(c.left), Range.new(c.right.children.first, c.right.children.last)
          # FIXME: 'not_in?' does not actually exist
          ProcWithSource.new("#{l}.not_in? #{r.inspect}") { |o| !o.send(l).in?(r) }
        else
          raise NotImplementedError, 'general Arel::Nodes::Not not implemented'
        end
      end

#       def visit_Arel_Table o
#       end

      def visit_Arel_Nodes_In o
        l, r =  visit(o.left), visit(o.right)
        ProcWithSource.new("#{l}.in? #{r.inspect}") { |o| o.send(l).in?(r) }
      end

      def visit_Arel_Nodes_NotIn o
        l, r =  visit(o.left), visit(o.right)
        # FIXME: 'not_in?' does not actually exist
        ProcWithSource.new("#{l}.not_in? #{r.inspect}") { |o| !o.send(l).in?(r) }
      end

      def visit_Arel_Nodes_And o
        o.children.map { |x| ProcWithSource.new("select {|o| o.#{visit(x).to_source}}") { |collection| collection.select {|obj| visit(x).call(obj) } } }
      end

#       def visit_Arel_Nodes_Or o
#       end

#       def visit_Arel_Nodes_Assignment o
#       end

      def visit_Arel_Nodes_Equality o
        l, r =  visit(o.left), visit(o.right)
        ProcWithSource.new("#{l} == #{r.inspect}") { |o| o.send(l) == r }
      end

      def visit_Arel_Nodes_NotEqual o
        l, r =  visit(o.left), visit(o.right)
        ProcWithSource.new("#{l} != #{r.inspect}") { |o| o.send(l) != r }
      end

#       def visit_Arel_Nodes_As o
#       end

#       def visit_Arel_Nodes_UnqualifiedColumn o
#       end


      def visit_Arel_Attributes_Attribute o
        o.name
      end
      alias :visit_Arel_Attributes_Integer :visit_Arel_Attributes_Attribute
      alias :visit_Arel_Attributes_Float :visit_Arel_Attributes_Attribute
      alias :visit_Arel_Attributes_Decimal :visit_Arel_Attributes_Attribute
      alias :visit_Arel_Attributes_String :visit_Arel_Attributes_Attribute
      alias :visit_Arel_Attributes_Time :visit_Arel_Attributes_Attribute
      alias :visit_Arel_Attributes_Boolean :visit_Arel_Attributes_Attribute

      def literal o; o end

      alias :visit_Arel_Nodes_BindParam  :literal
      alias :visit_Arel_Nodes_SqlLiteral :literal
      alias :visit_Bignum                :literal
      alias :visit_Fixnum                :literal

      def quoted o
        # don't actually quote...
        o
      end

      alias :visit_ActiveSupport_Multibyte_Chars :quoted
      alias :visit_ActiveSupport_StringInquirer  :quoted
      alias :visit_BigDecimal                    :quoted
      alias :visit_Class                         :quoted
      alias :visit_Date                          :quoted
      alias :visit_DateTime                      :quoted
      alias :visit_FalseClass                    :quoted
      alias :visit_Float                         :quoted
      alias :visit_Hash                          :quoted
      alias :visit_NilClass                      :quoted
      alias :visit_String                        :quoted
      alias :visit_Symbol                        :quoted
      alias :visit_Time                          :quoted
      alias :visit_TrueClass                     :quoted

#       def visit_Arel_Nodes_InfixOperation o
#         "#{visit o.left} #{o.operator} #{visit o.right}"
#       end

#       alias :visit_Arel_Nodes_Addition       :visit_Arel_Nodes_InfixOperation
#       alias :visit_Arel_Nodes_Subtraction    :visit_Arel_Nodes_InfixOperation
#       alias :visit_Arel_Nodes_Multiplication :visit_Arel_Nodes_InfixOperation
#       alias :visit_Arel_Nodes_Division       :visit_Arel_Nodes_InfixOperation

      def visit_Array o
        o.map { |x| visit x }
      end

      def quote value
        @connection.quote value, @dummy_column
      end
    end

    class ProcWithSource
      def initialize(source, &block)
        @source, @block = source, block
      end

      def call(*args)
        @block.call(*args)
      end

      def to_source
        @source
      end
    end

    class ProcWithSourceCollection
      def initialize(procs)
        @procs = procs.flatten.compact
      end

      def call(collection)
        @procs.inject(collection) do |result, lmd|
          lmd.call result
        end
      end

      def to_source
        @procs.map(&:to_source).join('.')
      end
    end
  end
end
