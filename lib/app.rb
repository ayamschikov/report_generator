class App
  def run(source)
    report = { totalUsers: 0 }

    # Подсчёт количества уникальных браузеров
    measure("report browsers") do
      report[:uniqueBrowsersCount] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq | wc -l`.to_i

      report[:totalSessions] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | wc -l`.to_i

      report[:allBrowsers] = `awk -F ',' '$1=="session" {print toupper($4)}' #{source} | sort | uniq`.split("\n").join(',')
    end

    report[:usersStats] = {}

    user = nil
    sessions = []

    measure("collect and parse with foreach") do
      File.foreach(source) do |line|
        cols = line.split(',')

        if cols[0] == 'user'
          if !sessions.empty?
            report = Report.create(report, user, sessions)
            sessions = []
          end
          user = Parsers::User.parse(line)
          report[:totalUsers] += 1
        end

        if cols[0] == 'session'
          sessions.push Parsers::Session.parse(line)
        end
      end
      report = Report.create(report, user, sessions)
    end

    measure("write to file") do
      File.write('result.json', "#{report.to_json}\n")
    end
  end
end
