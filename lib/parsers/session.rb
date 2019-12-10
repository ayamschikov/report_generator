# frozen_string_literal: true

require 'date'

module Parsers
  module Session
    def self.parse(fields)
      {
        user_id: fields[1],
        session_id: fields[2],
        browser: fields[3].upcase,
        time: fields[4],
        date: Date.iso8601(fields[5])
      }
    end
  end
end
