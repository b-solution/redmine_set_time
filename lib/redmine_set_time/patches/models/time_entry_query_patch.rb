module RedmineSetTime
  module Patches
    module Models
      module TimeEntryQueryPatch
        def self.included(base) # :nodoc:
          base.send(:include, InstanceMethods)

          base.class_eval do
            alias_method :available_columns_without_author, :available_columns
            alias_method :available_columns, :available_columns_with_author

            alias_method :initialize_available_filters_without_author, :initialize_available_filters
            alias_method :initialize_available_filters, :initialize_available_filters_with_author
          end
        end
      end

      module InstanceMethods

        def available_columns_with_author
          return @available_columns if @available_columns
          @available_columns = available_columns_without_author
          @available_columns << QueryColumn.new(:author, :sortable => lambda { User.fields_for_order_statement })
        end

        def initialize_available_filters_with_author
          initialize_available_filters_without_author
          add_available_filter("author_id",
                               :type => :list_optional, :values => lambda { author_values }
          )
        end

      end
    end
  end
end

unless TimeEntryQuery.included_modules.include?(RedmineSetTime::Patches::Models::TimeEntryQueryPatch)
  TimeEntryQuery.send(:include, RedmineSetTime::Patches::Models::TimeEntryQueryPatch)
end