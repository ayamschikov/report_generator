class App
  def initialize(options)
    @options = options
  end

  def run(source)
    users = []
    sessions = []

    # takes a bit more memory, saves a bit time
    measure("collect users and sessions") do
      users = `awk -F ',' '$1=="user" {print $0}' #{source}`.split("\n").map {|u| Parsers::User.parse(u)}
      sessions = `awk -F ',' '$1=="session" {print $0}' #{source}`.split("\n").map {|u| Parsers::Session.parse(u)}
    end

    report = Report.create(users, sessions)

    measure("write to file") do
      File.write('result.json', "#{report.to_json}\n")
    end
  end
end
