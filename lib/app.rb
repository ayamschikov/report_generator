class App
  def run(source)
    users = []

    # takes a bit more memory, saves a bit time
    measure("collect users and sessions") do
      users = `awk -F ',' '$1=="user" {print $0}' #{source}`.split("\n").lazy.map {|u| Parsers::User.parse(u)}
    end

    report = {}
    report = Report.create(report, users, source)

    measure("write to file") do
      File.write('result.json', "#{report.to_json}\n")
    end
  end
end
