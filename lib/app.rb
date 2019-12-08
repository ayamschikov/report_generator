class App
  def initialize(options)
    @options = options
  end

  def run(source)
    users = []
    sessions = []

    measure("collect users and sessions") do
      File.foreach(source) do |line|
        cols = line.split(',')
        users.push Parsers::User.parse(line) if cols[0] == 'user'
        sessions.push Parsers::Session.parse(line) if cols[0] == 'session'
      end
    end

    report = Report.create(users, sessions)

    rep = ""
    measure("to json") do
      rep = report.to_json
    end
    measure("write to file") do
      File.write('result.json', "#{rep}\n")
    end
  end
end
