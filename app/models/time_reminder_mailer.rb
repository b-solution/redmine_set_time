class TimeReminderMailer
  def self.send_to_admin
    day = Date.today
    if  Setting.plugin_redmine_set_time["send_mail_on_#{day.wday}"]
      user_filled = TimeEntry.where(spent_on: day).pluck(:user_id).uniq
      not_filled = User.active.where(admin: false).where.not(id: user_filled)
      admin = User.where(admin: true).first
      Mailer.time_not_filled(admin, not_filled).deliver
    end

  end

  def self.send_to_users
    day = Date.today
    if Setting.plugin_redmine_set_time["daily_capacity_cf_id"] && Setting.plugin_redmine_set_time["send_mail_on_#{day.wday}"]
      User.active.where(admin: false).each do |user|
        daily_capacity = user.custom_field_values.detect{|cfv| cfv.custom_field_id.to_s == Setting.plugin_redmine_set_time["daily_capacity_cf_id"]}&.value
        if daily_capacity
          daily_capacity = daily_capacity.to_f
          logged_time = TimeEntry.where(spent_on: day).sum(:hours)

          if logged_time <= (daily_capacity - Setting.plugin_redmine_set_time["threshold"].to_i)
            Mailer.user_time_reminder(user, logged_time, daily_capacity , (daily_capacity - Setting.plugin_redmine_set_time["threshold"].to_i)).deliver
          end

          if logged_time >= (daily_capacity + Setting.plugin_redmine_set_time["threshold"].to_i)
            Mailer.user_time_reminder(user, logged_time, daily_capacity, (daily_capacity + Setting.plugin_redmine_set_time["threshold"].to_i) ).deliver
          end
        end
      end
    end

  end

end