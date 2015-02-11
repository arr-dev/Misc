require 'net/https'
require 'yaml'
require 'ostruct'

class AddToMixcloudPlaylist

  Config = OpenStruct.new(YAML.load_file('mixcloud.yml'))
  Host = URI("https://www.mixcloud.com")

  def call
    return if links.empty?

    verify_login!

    links.each do |link|

      path = parse_path(link)
      request = build_request(path)

      response = fire!(request)

      puts "response: #{response.inspect}" if debug? || !response.is_a?(Net::HTTPOK)
    end
  end

  private

  def verify_login!
    req = Net::HTTP::Get.new('/')
    req.add_field('Cookie', cookies)

    res = fire!(req)

    raise 'Invalid session id!' unless res.body.include?('_loggedIn": true')
  end

  def fire!(request)
     Net::HTTP.start(Host.host, Host.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |h|
      h.request(request)
    end
  end

  def links
    @links ||= File.read('links.txt').split("\n").map(&:strip)
  end

  def cookies
    "s=#{Config.sid}; csrftoken=#{Config.csrftoken}"
  end

  def debug?
    ENV.has_key?('DEBUG')
  end

  def build_request(path)
    url = "/playlists#{path}add-to-collection/"
    req = Net::HTTP::Post.new(url)

    req.add_field('Cookie', "#{cookies}")
    req.add_field('Origin', Host.to_s)
    req.add_field('Content-Type', "application/x-www-form-urlencoded; charset=UTF-8")
    req.add_field('Accept', 'application/json, text/javascript, */*; q=0.01')
    req.add_field('Referer', "#{Host.to_s}#{path}")
    req.add_field('X-CSRFToken', "#{Config.csrftoken}")
    req.add_field('X-Requested-With', 'XMLHttpRequest')

    req.body = "action=add&playlist_slug=#{Config.playlist_name}"

    puts "req: #{req.inspect} #{req.to_hash}" if debug?
    req
  end

  def parse_path(link)
    uri = URI(link)
    req = Net::HTTP::Get.new(uri)
    res = fire!(req)
    puts "res: #{res.inspect}" if debug? || !res.is_a?(Net::HTTPFound)

    path = case res
           when Net::HTTPFound
             URI(res['location']).path
           when Net::HTTPOK
             uri.path
           else
             raise "result is #{res.inspect}"
           end
    puts "parsed path: #{path}" if debug?
    path
  end
end

AddToMixcloudPlaylist.new.call
