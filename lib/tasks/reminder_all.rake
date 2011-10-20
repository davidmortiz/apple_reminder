# redMine - project management software
# Copyright (C) 2008  Jean-Philippe Lang
#
# Modified by David Ortiz
# This script has been heavily rewritten for the Apple use case.
# We don't care about due dates as much as we care about 
# stale data.

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


desc <<-END_DESC
Send reminders about issues due in the next days.

Available options:
  * days     => number of days to remind about (defaults to 7)
  * tracker  => id of tracker (defaults to all trackers)
  * project  => id or identifier of project (defaults to all projects)

Example:
  rake redmine:send_reminders_all days=7 RAILS_ENV="production"
END_DESC
require File.expand_path(File.dirname(__FILE__) + "/../../../../../config/environment")
require "rake"
require "actionmailer"

class Reminder_all < ActionMailer::Base
  @mailSubject = "Reminder from Apple Data Manager"
  @base_url = "http://localhost:3000/issue/"
  
  def self.reminders_all(options={})
    days = options[:days] || 7
    project = options[:project] ? Project.find(options[:project]) : nil
    tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil

    s = ARCondition.new ["#{IssueStatus.table_name}.is_closed = ? AND #{Issue.table_name}.updated_on <= ?", false, (Time.now - days.days).to_date]
    s << "#{Project.table_name}.status = #{Project::STATUS_ACTIVE}"
    s << "#{Issue.table_name}.project_id = #{project.id}" if project
    s << "#{Issue.table_name}.tracker_id = #{tracker.id}" if tracker
    issues_by_assignee = Issue.find(:all, :include => [:status, :assigned_to, :project, :tracker, :author],
                                          :conditions => s.conditions
                                    ).group_by(&:assigned_to)
    issues_by_assignee.each do |assignee, issues|
	issue_items = Array.new

		if(assignee != nil && issues != nil)	
			issues.each do | issue |
			assignees << MailIssue.new(issue.id, issue.subject, issue)
			end
			
		end
		ApplicationMailer.create_signed_up("davidortz@childrens.harvard.edu") 
		puts mail_text
	end
end
namespace :redmine do
  task :send_reminders_all => :environment do
    options = {}
    options[:days] = ENV['days'].to_i if ENV['days']
    options[:project] = ENV['project'] if ENV['project']
    options[:tracker] = ENV['tracker'].to_i if ENV['tracker']

   	Reminder_all.reminders_all(options)
  end
end
end

class MailIsue
	attr_accessor :issue_id, :subject, :author

	def initialize(issue_id, subject, author)
		@issue_id = issue_id
		@subject = subject
		@author = author
	end

end
