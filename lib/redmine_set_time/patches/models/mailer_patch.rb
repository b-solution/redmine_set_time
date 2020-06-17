module RedmineSetTime
  module Patches
    module Models
      module MailerPatch
        def self.included(base)
          # base.send :include, InstanceMethods
          # base.send :extend, ClassMethods
          base.class_eval do
            def user_time_reminder(user, time_logged, capacity, minimum_needed)
              @user = user
              @time_logged = time_logged
              @minimum_needed = minimum_needed
              @capacity = capacity
              mail :to => user, :subject => "Log Time reminder"
            end

            def time_not_filled(admin, users)
              @admin = admin
              @users = users
              mail :to => @admin, :subject => "Log Time Not filled"
            end
          end
        end
      end
    end
  end
end

unless Mailer.included_modules.include?( RedmineSetTime::Patches::Models::MailerPatch)
  Mailer.send(:include,  RedmineSetTime::Patches::Models::MailerPatch)
end
