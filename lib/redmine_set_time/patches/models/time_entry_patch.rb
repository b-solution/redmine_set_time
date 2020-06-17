module RedmineSetTime
  module Patches
    module Models
      module TimeEntryPatch
        def self.included(base) # :nodoc:
          base.send(:include, InstanceMethods)

          base.class_eval do
            safe_attributes 'user_id'


            belongs_to :author, :class_name => 'User'
            validates_presence_of :author_id, :issue_id
            before_validation :set_author_if_nil
            alias_method :validate_time_entry_without_author, :validate_time_entry
            alias_method :validate_time_entry, :validate_time_entry_with_author
          end
        end
      end

      module InstanceMethods
        def validate_time_entry_with_author
          validate_time_entry_without_author
          errors.add :user_id, :invalid if (user_id != author_id && !self.assignable_users.map(&:id).include?(user_id))
        end

        def set_author_if_nil
          self.author = User.current if author.nil?
        end

        def assignable_users
          users = []
          if project
            users = project.members.active.preload(:user)
            users = users.map(&:user).select{ |u| u.allowed_to?(:log_time, project) }
          end
          users << User.current if User.current.logged? && !users.include?(User.current)
          users
        end
      end
    end
  end
end

unless TimeEntry.included_modules.include?( RedmineSetTime::Patches::Models::TimeEntryPatch)
  TimeEntry.send(:include,  RedmineSetTime::Patches::Models::TimeEntryPatch)
end