module DataMapper
  module Adapters
    class DataObjectsAdapter < AbstractAdapter
      def select_statement(query)
        qualify  = query.links.any?
        fields   = query.fields
        order_by = query.order
        group_by = if query.unique?
          group_by_fields = order_by.collect { |direction| direction.target.property if direction.target.respond_to?(:property) }
          Set.new(fields).merge(group_by_fields).select { |property| property.kind_of?(Property) }
        end

        conditions_statement, bind_values = conditions_statement(query.conditions, qualify)

        statement = "SELECT #{columns_statement(fields, qualify)}"
        statement << " FROM #{quote_name(query.model.storage_name(name))}"
        statement << " #{join_statement(query, bind_values, qualify)}"   if qualify
        statement << " WHERE #{conditions_statement}"                    unless DataMapper::Ext.blank?(conditions_statement)
        statement << " GROUP BY #{columns_statement(group_by, qualify)}" if group_by && group_by.any?
        statement << " ORDER BY #{order_statement(order_by, qualify)}"   if order_by && order_by.any?

        add_limit_offset!(statement, query.limit, query.offset, bind_values)

        return statement, bind_values
      end
    end
  end
end
