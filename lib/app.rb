# frozen_string_literal: true

require 'json'

class App
  def run(source)
    report = {}
    user = nil
    sessions = []

    report[:totalUsers] = `awk -F ',' '$1=="user" {print $1}' #{source} | wc -l`.to_i
    report[:uniqueBrowsersCount] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq | wc -l`.to_i

    report[:totalSessions] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | wc -l`.to_i

    report[:allBrowsers] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq`.split("\n").join(',')

    report[:usersStats] = {}

    File.foreach(source) do |line|
      fields = line.split(',')

      case fields[0]
      when 'user'
        unless sessions.empty?
          user_key = "#{user[:first_name]} #{user[:last_name]}"
          report[:usersStats][user_key] = Report.collect_stats_from_sessions(sessions)
          sessions = []
        end
        user = Parsers::User.parse(fields)
      when 'session'
        sessions.push Parsers::Session.parse(fields)
      end
    end

    user_key = "#{user[:first_name]} #{user[:last_name]}"
    report[:usersStats][user_key] = Report.collect_stats_from_sessions(sessions)

    File.write('result.json', report.to_json)
  end
end
