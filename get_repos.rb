
require 'bundler'
require 'dotenv/load'
require_relative 'lib/bitbucket'
require_relative 'lib/stash'
require_relative 'lib/git'

def mirror_hageltech_repos
  bitbucket = BitBucket.new(ENV['BITBUCKET_USERNAME'], ENV['BITBUCKET_PASSWORD'], 'hageltech')
  local_repos = Git::all_repos('repos')
  local_repos.each do |repo|
    repo_info = bitbucket.repo(repo[:name], repo[:project])
    remote = repo_info['links']['clone'].find { |l| l['name'] == 'ssh' }['href']
    puts "Created repo #{remote}"
    Git::push(repo[:dir], remote)
    puts "Pushed to BitBucket\n\n"
  end
end

def mirror_private_repos
  bitbucket = BitBucket.new(ENV['BITBUCKET_USERNAME'], ENV['BITBUCKET_PASSWORD'],'haimg')
  local_repos = Git::all_repos('private')
  local_repos.each do |repo|
    repo_info = bitbucket.repo(repo[:name], nil)
    remote = repo_info['links']['clone'].find { |l| l['name'] == 'ssh' }['href']
    puts "Created repo #{remote}"
    Git::push(repo[:dir], remote)
    puts "Pushed to BitBucket\n\n"
  end
end

#def list_all_repos
#  bitbucket = BitBucket.new('haimg')
#
#end

mirror_private_repos
