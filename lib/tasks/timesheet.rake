namespace :redmine do
  namespace :timesheet do

    desc "send email to not filled user"
    task :send_to_admin => [:environment] do
      TimeReminderMailer.send_to_admin
    end

    task :send_to_user => [:environment] do
      TimeReminderMailer.send_to_users
    end

  end
end