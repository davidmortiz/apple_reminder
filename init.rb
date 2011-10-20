require 'redmine'

Redmine::Plugin.register :redmine_reminder do
  name 'Apple Reminder'
  author 'Milan Stastny of ALVILA SYSTEMS, Heavily Modified by David Ortiz for CHIP'
  description 'E-mail notification of issues due date you are involved in (Assignee, Author, Watcher)'
  version '0.0.1'
  author_url 'http://www.alvila.com, http://chip.org'
end

