require 'bundler'
require 'dotenv/load'
require_relative 'lib/bitbucket'
require_relative 'lib/git'

def backup_location
  Pathname.new(ENV['BACKUP_LOCATION'] || './repos')
end

def all_repos
  bitbucket = BitBucket.new(ENV['BITBUCKET_USERNAME'], ENV['BITBUCKET_PASSWORD'])
  bitbucket.all_repos
end

def repo_url(repo)
  repo['links']['clone'].find { |l| l['name'] == 'https' }['href']
    .sub("https://#{ENV['BITBUCKET_USERNAME']}@", "https://#{ENV['BITBUCKET_USERNAME']}:#{ENV['BITBUCKET_PASSWORD']}@")
end

def backup
  puts "Backup up all repos in account '#{ENV['BITBUCKET_USERNAME']}' ..."
  repos = all_repos
  File.open(backup_location + 'repos.json', 'w').write(JSON.pretty_generate(repos))
  repos.map! do |repo|
    {
      username: repo['owner']['username'] || ENV['BITBUCKET_USERNAME'],
      project: repo.dig('project', 'key').to_s,
      name: repo['name'],
      url: repo_url(repo)
    }
  end
  repos.sort_by { |repo| repo[:username] + repo[:project] + repo[:name] }.each do |repo|
    Git::backup_repo(backup_location, repo[:username], repo[:project], repo[:name], repo[:url])
  end
  puts "Backup has completed successfully!"
end

backup
