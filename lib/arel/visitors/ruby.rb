require 'bigdecimal'
require 'date'

module Arel
  module Visitors
    class Ruby < Arel::Visitors::Visitor
      attr_accessor :last_column

      def initialize
        @connection = Object.new.extend(ActiveRecord::ConnectionAdapters::Quoting)
        @chains = []
      end

      def accept object
        self.last_column = nil
        super
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
        [
          o.cores.map { |x| visit_Arel_Nodes_SelectCore x }.join,
          ("#{o.orders.map { |x| visit_Arel_Nodes_OrderCore x }.join('.')}" unless o.orders.empty?),
          (visit(o.offset) if o.offset),
          (visit(o.limit) if o.limit),
        ].compact.delete_if {|e| e.respond_to?(:empty?) && e.empty? }.join '.'
      end

      def visit_Arel_Nodes_SelectCore o
        [
#           ("#{o.projections.map { |x| visit x }.join ', '}" unless o.projections.empty?),
#           (visit(o.source) if o.source && !o.source.empty?),
          ("#{o.wheres.map { |x| visit x }.join '.' }" unless o.wheres.empty?),
          ("#{o.groups.map { |x| visit x }.join '.' }" unless o.groups.empty?)
#           (visit(o.having) if o.having),
        ].compact.join '.'
      end

      def visit_Arel_Nodes_OrderCore order
        order.split(',').map do |o|
          attr, direction = o.split(/\s+/)
          "sort_by(&:#{visit attr})#{'.reverse' if direction == 'desc'}"
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
        "from(#{visit o.expr})"
      end

      def visit_Arel_Nodes_Limit o
        "take(#{visit o.expr})"
      end

#       def visit_Arel_Nodes_Grouping o
#       end

#       def visit_Arel_Nodes_Ascending o
#       end

#       def visit_Arel_Nodes_Descending o
#       end

      def visit_Arel_Nodes_Group o
        "group_by {|g| g.#{visit o.expr}}"
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

#       def visit_Arel_Nodes_Between o
#       end

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

#       def visit_Arel_Nodes_Not o
#       end

#       def visit_Arel_Table o
#       end

#       def visit_Arel_Nodes_In o
#       end

#       def visit_Arel_Nodes_NotIn o
#       end

      def visit_Arel_Nodes_And o
        o.children.map { |x| "select {|o| #{visit x}}"}.join '.'
      end

#       def visit_Arel_Nodes_Or o
#       end

#       def visit_Arel_Nodes_Assignment o
#       end

      def visit_Arel_Nodes_Equality o
        "#{visit o.left} == #{visit o.right}"
      end

#       def visit_Arel_Nodes_NotEqual o
#       end

#       def visit_Arel_Nodes_As o
#       end

#       def visit_Arel_Nodes_UnqualifiedColumn o
#       end


      def visit_Arel_Attributes_Attribute o
        self.last_column = o.name
        "o.#{o.name}"
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
        quote(o, last_column)
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

#       def visit_Array o
#         o.map { |x| visit x }.join(', ')
#       end

      def quote value, column = nil
        @connection.quote value, column
      end
    end
  end
end
