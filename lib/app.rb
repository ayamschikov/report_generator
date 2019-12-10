# frozen_string_literal: true

require 'json'

class App
  def run(source)
    report = {}
    user = nil
    sessions = []
    batch_size = 20000
    rep_limit = 500
    user_stats = []
    need_comma = false
    dest = 'result.json'.freeze

    # prepare result.json with generic stats
    report[:totalUsers] = `awk -F ',' '$1=="user" {print $1}' #{source} | wc -l`.to_i
    report[:uniqueBrowsersCount] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq | wc -l`.to_i

    report[:totalSessions] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | wc -l`.to_i

    report[:allBrowsers] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq`.split("\n").join(',')

    report[:usersStats] = {}

    # write json file
    File.write(dest, report.to_json)

    # determine offset where to write userStats
    offset = report.to_json.length - 2

    File.open(source, 'r') do |file|
      file.lazy.each_slice(batch_size) do |lines|

        lines.each do |line|
          fields = line.split(',')

          case fields[0]
          when 'user'
            unless sessions.empty?
              user_key = "#{user[:first_name]} #{user[:last_name]}"
              user_stats << "\"#{user_key}\":#{Report.collect_stats_from_sessions(sessions).to_json}"
              sessions = []
            end
            user = Parsers::User.parse(fields)
          when 'session'
            sessions.push Parsers::Session.parse(fields)
          end
        end

        if user_stats.count == rep_limit
          need_comma = true
          offset += IO.binwrite(dest, user_stats.join(','), offset)
          user_stats = []
        end
      end
    end

    # write final userStats
    user_key = "#{user[:first_name]} #{user[:last_name]}"
    user_stats << "\"#{user_key}\":#{Report.collect_stats_from_sessions(sessions).to_json}"
    IO.binwrite(dest, need_comma ? ",#{user_stats.join(',')}}}" : "#{user_stats.join(',')}}}", offset)
  end
end
