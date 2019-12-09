module Report
  module_function
  def create(report, user, sessions)
    # Статистика по пользователям
    user_object = User.new(attributes: user, sessions: sessions)

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, user_object) do |user|
      { sessionsCount: user.sessions.count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, user_object) do |user|
      sessions_time = user.sessions.map {|s| s[:time].to_i}
      { totalTime: sessions_time.sum.to_s + ' min.',
        longestSession: sessions_time.max.to_s + ' min.' }
    end

    collect_stats_from_users(report, user_object) do |user|
      browsers = user.sessions.map {|s| s[:browser]}
      { browsers: browsers.sort.join(', '),
        usedIE: browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
        alwaysUsedChrome: browsers.all? { |b| b =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, user_object) do |user|
      { dates: user.sessions.map{|s| Date.iso8601(s[:date])}.sort.reverse }
    end

    report
  end

  def collect_stats_from_users(report, user, &block)
    user_key = "#{user.attributes[:first_name]}" + ' ' + "#{user.attributes[:last_name]}"
    report[:usersStats][user_key] ||= {}
    report[:usersStats][user_key].merge!(block.call(user))
  end
end
