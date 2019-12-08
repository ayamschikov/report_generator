module Report
  module_function
  def create(users, sessions)
    report = {}

    sessions_by_user_id = {}

    measure("sessions_by_user") do
      sessions.each do |session|
        sessions_by_user_id[session['user_id']] ||= []
        sessions_by_user_id[session['user_id']] << session
      end
    end

    report[:totalUsers] = users.count


    # Подсчёт количества уникальных браузеров
    measure("report browsers") do
      unique_browsers = sessions.map { |s| s['browser'] }.uniq

      report['uniqueBrowsersCount'] = unique_browsers.count

      report['totalSessions'] = sessions.count

      report['allBrowsers'] = unique_browsers.sort.join(',')
    end

    # Статистика по пользователям

    report['usersStats'] = {}

    measure("users each") do
      users.each do |user|
        attributes = user
        user_sessions = sessions_by_user_id[user['id']]
        user_object = User.new(attributes: attributes, sessions: user_sessions)

        # Собираем количество сессий по пользователям
        collect_stats_from_users(report, user_object) do |user|
          { 'sessionsCount' => user.sessions.count }
        end

        # Собираем количество времени по пользователям
        collect_stats_from_users(report, user_object) do |user|
          s_time = user.sessions.map {|s| s['time'].to_i}
          { 'totalTime' => s_time.sum.to_s + ' min.',
            'longestSession' => s_time.max.to_s + ' min.' }
        end

        # Браузеры пользователя через запятую
        collect_stats_from_users(report, user_object) do |user|
          br = user.sessions.map {|s| s['browser']}
          { 'browsers' => br.sort.join(', '),
            'usedIE' => br.any? { |b| b =~ /INTERNET EXPLORER/ },
            'alwaysUsedChrome' => br.all? { |b| b =~ /CHROME/ } }
        end

        # Даты сессий через запятую в обратном порядке в формате iso8601
        collect_stats_from_users(report, user_object) do |user|
          { 'dates' => user.sessions.map{|s| Date.iso8601(s['date'])}.sort.reverse }
        end
      end
    end

    report
  end

  def collect_stats_from_users(report, user, &block)
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key].merge!(block.call(user))
  end
end
# report['usersStats'] = {}

# # Собираем количество сессий по пользователям
# collect_stats_from_users(report, users_objects) do |user|
#   { 'sessionsCount' => user.sessions.count }
# end

# # Собираем количество времени по пользователям
# collect_stats_from_users(report, users_objects) do |user|
#   { 'totalTime' => user.sessions.map {|s| s['time'].to_i}.sum.to_s + ' min.' }
# end

# # Выбираем самую длинную сессию пользователя
# collect_stats_from_users(report, users_objects) do |user|
#   { 'longestSession' => user.sessions.map {|s| s['time'].to_i}.max.to_s + ' min.' }
# end

# # Браузеры пользователя через запятую
# collect_stats_from_users(report, users_objects) do |user|
#   { 'browsers' => user.sessions.map {|s| s['browser']}.sort.join(', ') }
# end

# # Хоть раз использовал IE?
# collect_stats_from_users(report, users_objects) do |user|
#   { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b =~ /INTERNET EXPLORER/ } }
# end

# # Всегда использовал только Chrome?
# collect_stats_from_users(report, users_objects) do |user|
#   { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b =~ /CHROME/ } }
# end

# # Даты сессий через запятую в обратном порядке в формате iso8601
# collect_stats_from_users(report, users_objects) do |user|
#   { 'dates' => user.sessions.map{|s| Date.iso8601(s['date'])}.sort.reverse }
# end
