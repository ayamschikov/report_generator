# frozen_string_literal: true

module Report
  module_function

  def collect_stats_from_sessions(sessions)
    sessions_time = sessions.map { |s| s[:time].to_i }
    browsers = sessions.map { |s| s[:browser] }

    {
      sessionsCount: sessions.count,
      totalTime: sessions_time.sum.to_s + ' min.',
      longestSession: sessions_time.max.to_s + ' min.',
      browsers: browsers.sort.join(', '),
      usedIE: browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      alwaysUsedChrome: browsers.all? { |b| b =~ /CHROME/ },
      dates: sessions.map { |s| s[:date] }.sort.reverse
    }
  end
end
