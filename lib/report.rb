# frozen_string_literal: true

module Report
  module_function

  def create(report, user, sessions)
    sessions_time = sessions.map { |s| s[:time].to_i }
    browsers = sessions.map { |s| s[:browser] }

    user_key = user[:first_name].to_s + ' ' + user[:last_name].to_s
    report[:usersStats][user_key] =
      {
        sessionsCount: sessions.count,
        totalTime: sessions_time.sum.to_s + ' min.',
        longestSession: sessions_time.max.to_s + ' min.',
        browsers: browsers.sort.join(', '),
        usedIE: browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
        alwaysUsedChrome: browsers.all? { |b| b =~ /CHROME/ },
        dates: sessions.map { |s| s[:date] }.sort.reverse
      }

    report
  end
end
