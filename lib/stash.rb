require 'stash-client'

class HtStash
  attr_reader :connection, :user

  def initialize(username, password)
    @connection = Stash::Client.new(url: 'https://intra.hageltech.ca/stash/', credentials: "#{username}:#{password}")
  end

  def repos
    connection.repositories
        .map { |r| {
          project: r['project']['key'],
          name: r['name'],
          url: r['links']['clone'].find { |l| l['name'] == 'ssh' }['href']
        }
    }
  end

  def clone_all
    repos.each do |repo|
      FileUtils.mkdir_p "repos/#{repo[:project]}"
      target = "repos/#{repo[:project]}/#{repo[:name]}"
      if File::directory? target
        puts "Directory #{target} exists, skipping!"
      else
        puts "Cloning #{target}..."
        system "git clone --mirror #{repo[:url]} #{target}" or raise 'Could not clone the repo!'
        puts "\n\n"
      end
    end
  end
end
