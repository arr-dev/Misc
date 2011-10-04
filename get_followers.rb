#!/usr/bin/env ruby

puts RUBY_VERSION
puts RUBY_RELEASE_DATE
require 'thread'
require 'rubygems'
require 'active_support'

TWCMD = '/usr/bin/env twurl'
FOLLOWERS_URL = '/1/followers/ids.json'
USER_LOOKUP_URL = '/1/users/lookup.json?user_id='

f_response = %x[#{TWCMD} #{FOLLOWERS_URL}]

followers = ActiveSupport::JSON.decode(f_response)

d_response = %x[#{TWCMD} #{USER_LOOKUP_URL}#{followers.sort.join(',')}]

data = ActiveSupport::JSON.decode(d_response)


fp = File.open(Time.new.strftime("%Y%m%d").to_s + '_twflw.txt', 'w')

data.sort{ |x, y| x["id"] <=> y["id"] }.each do |user|
  fp.puts "#{user['id']} | #{user['screen_name']} | #{user['name']}\n"
end

fp.close

