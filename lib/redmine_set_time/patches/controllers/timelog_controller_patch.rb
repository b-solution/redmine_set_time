module RedmineSetTime
  module Patches
    module Controllers
      module TimelogControllerPatch
        def self.included(base) # :nodoc:
          base.send(:include, InstanceMethods)

          base.class_eval do
            alias_method :new_without_author, :new
            alias_method :new, :new_with_author

            alias_method :create_without_author, :create
            alias_method :create, :create_with_author

            before_action :authorize_logging_time_for_other_users, :only => [:create, :update]
          end
        end
      end

      module InstanceMethods
        def new_with_author
          @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :author => User.current, :spent_on => User.current.today)
          new_without_author
        end

        def create_with_author
          @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :author => User.current, :user => User.current, :spent_on => User.current.today)
          @time_entry.safe_attributes = params[:time_entry]
          @time_entry.user_id = params[:time_entry][:user_id] if params[:time_entry][:user_id]
          if @time_entry.project && !User.current.allowed_to?(:log_time, @time_entry.project)
            render_403
            return
          end

          call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

          if @time_entry.save
            respond_to do |format|
              format.html {
                flash[:notice] = l(:notice_successful_create)
                if params[:continue]
                  options = {
                      :time_entry => {
                          :project_id => params[:time_entry][:project_id],
                          :issue_id => @time_entry.issue_id,
                          :activity_id => @time_entry.activity_id
                      },
                      :back_url => params[:back_url]
                  }
                  if params[:project_id] && @time_entry.project
                    redirect_to new_project_time_entry_path(@time_entry.project, options)
                  elsif params[:issue_id] && @time_entry.issue
                    redirect_to new_issue_time_entry_path(@time_entry.issue, options)
                  else
                    redirect_to new_time_entry_path(options)
                  end
                else
                  redirect_back_or_default project_time_entries_path(@time_entry.project)
                end
              }
              format.api  { render :action => 'show', :status => :created, :location => time_entry_url(@time_entry) }
            end
          else
            respond_to do |format|
              format.html { render :action => 'new' }
              format.api  { render_validation_errors(@time_entry) }
            end
          end
        end

        def authorize_logging_time_for_other_users
          if !User.current.allowed_to?(:log_time_for_other_users, @project) && params['time_entry'].present? && params['time_entry']['user_id'].present? && params['time_entry']['user_id'].to_i != User.current.id
            render_error :message => l(:error_not_allowed_to_log_time_for_other_users), :status => 403
            return false
          end
        end
      end
    end
  end
end

unless TimelogController.included_modules.include?(RedmineSetTime::Patches::Controllers::TimelogControllerPatch)
  TimelogController.send(:include, RedmineSetTime::Patches::Controllers::TimelogControllerPatch)
end