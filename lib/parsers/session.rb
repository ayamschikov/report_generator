# frozen_string_literal: true

module Parsers
  module Session
    def self.parse(session)
      fields = session.split(',')
      {
        user_id: fields[1],
        session_id: fields[2],
        browser: fields[3].upcase,
        time: fields[4],
        date: fields[5]
      }
    end
  end
end
