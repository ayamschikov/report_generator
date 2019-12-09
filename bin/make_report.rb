#! /usr/bin/env ruby
# frozen_string_literal: true

require 'require_all'
require_rel '../lib'

source = ARGV[0]

measure('total script') do
  App.new.run(source)
end
