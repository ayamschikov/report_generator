module Report
  module_function
  def create(report, users, source)
    report[:totalUsers] = users.count

    sessions_by_user_id = {}
    measure("sessions_by_user") do
      sessions = `awk -F ',' '$1=="session" {print $0}' #{source}`.split("\n").lazy.map {|u| Parsers::Session.parse(u)}

      sessions.each do |session|
        sessions_by_user_id[session['user_id']] ||= []
        sessions_by_user_id[session['user_id']] << session
      end
    end
    # Подсчёт количества уникальных браузеров
    measure("report browsers") do
      report['uniqueBrowsersCount'] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq | wc -l`.to_i

      report['totalSessions'] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | wc -l`.to_i

      # report['allBrowsers'] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | sed -z 's/\n/,/g'`
      report['allBrowsers'] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq`.gsub("\n", ',')
    end

    # Статистика по пользователям

    report['usersStats'] = {}

    measure("users each collect") do
      users.each do |user|
        # user_session = `awk -F ',' '$1=="session" && $2=="#{user['id']}" {print $0}' #{source}`.split("\n").map {|u| Parsers::Session.parse(u)}
        user_object = User.new(attributes: user, sessions: 
                               sessions_by_user_id[user['id']]
                               # user_session
                              )

        # Собираем количество сессий по пользователям
        collect_stats_from_users(report, user_object) do |user|
          { 'sessionsCount' => user.sessions.count }
        end

        # Собираем количество времени по пользователям
        collect_stats_from_users(report, user_object) do |user|
          sessions_time = user.sessions.map {|s| s['time'].to_i}
          { 'totalTime' => sessions_time.sum.to_s + ' min.',
            'longestSession' => sessions_time.max.to_s + ' min.' }
        end

        collect_stats_from_users(report, user_object) do |user|
          browsers = user.sessions.map {|s| s['browser']}
          { 'browsers' => browsers.sort.join(', '),
            'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
            'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ } }
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
