Redmine::Plugin.register :redmine_set_time do
  name 'Redmine Set Time plugin'
  author 'Bilel kedidi'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://www.github.com/bilel-kedidi/redmine_set_time'
  author_url 'https://www.github.com/bilel-kedidi'

  project_module :time_tracking do
    permission :log_time_for_other_users, :require => :member
  end

  settings default: {
      'send_mail_on_1' => "1",
      'send_mail_on_2' => "1",
      'send_mail_on_3' => "1",
      'send_mail_on_4' => "1",
      'send_mail_on_5' => "1",
      "threshold" => "3"

  }, partial: 'redmine_set_time/settings'
end

require 'redmine_set_time/patches/controllers/timelog_controller_patch'
# require 'redmine_set_time/patches/helpers/timelog_helper_patch'
require 'redmine_set_time/patches/models/time_entry_patch'
require 'redmine_set_time/patches/models/mailer_patch'
require 'redmine_set_time/patches/models/time_entry_query_patch'