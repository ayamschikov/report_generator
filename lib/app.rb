# frozen_string_literal: true
require 'json'

class App
  def run(source)
    report = {}

    # Подсчёт количества уникальных браузеров
    measure('report browsers') do
      report[:totalUsers] = `awk -F ',' '$1=="user" {print $1}' #{source} | wc -l`.to_i
      report[:uniqueBrowsersCount] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq | wc -l`.to_i

      report[:totalSessions] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | wc -l`.to_i

      report[:allBrowsers] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq`.split("\n").join(',')
    end

    report[:usersStats] = {}

    user = nil
    sessions = []

    measure('collect and parse with foreach') do
      File.foreach(source) do |line|
        cols = line.split(',')

        case cols[0]
        when 'user'
          unless sessions.empty?
            report = Report.create(report, user, sessions)
            sessions = []
          end
          user = Parsers::User.parse(line)
        when 'session'
          sessions.push Parsers::Session.parse(line)
        end
      end
      report = Report.create(report, user, sessions)
    end

    measure('write to file') do
      File.write('result.json', report.to_json)
    end
  end
end
