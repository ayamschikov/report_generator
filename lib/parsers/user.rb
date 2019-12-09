# frozen_string_literal: true

module Parsers
  module User
    def self.parse(user)
      fields = user.split(',')
      {
        id: fields[1],
        first_name: fields[2],
        last_name: fields[3],
        age: fields[4]
      }
    end
  end
end
