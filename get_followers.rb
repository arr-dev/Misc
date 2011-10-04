#!/usr/bin/env ruby

require 'thread'
require 'rubygems'
require 'active_support'

TWCMD = '/home/nenadpet/.rvm/gems/ruby-1.8.7-p352@skinflips/bin/twurl'
FOLLOWERS_URL = '/1/followers/ids.json?screen_name=soulrblkg'
USER_LOOKUP_URL = '/1/users/lookup.json?user_id='

f_response = %x[#{TWCMD} #{FOLLOWERS_URL}]

followers = ActiveSupport::JSON.decode(f_response)

d_response = %x[#{TWCMD} #{USER_LOOKUP_URL}#{followers.sort.join(',')}]

data = ActiveSupport::JSON.decode(d_response)

data.sort{ |x, y| x["id"] <=> y["id"] }.each do |user|
  puts "#{user['id']} | #{user['screen_name']} | #{user['name']}"
end
