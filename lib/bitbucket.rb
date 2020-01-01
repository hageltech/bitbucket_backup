require 'faraday'
require 'faraday_middleware'

class BitBucket
  attr_reader :connection, :team

  def initialize(username, password, team=nil)
    @team = team || username
    @connection = Faraday.new 'https://api.bitbucket.org/2.0/' do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
      conn.basic_auth(username, password)
    end
  end

  # Get or create a repo with a given name, in a given project
  def repo(name, project)
    path = "repositories/#{team}/#{name}"
    repo = connection.get(path)
    return repo.body if repo.success?
    payload = { scm: :git, is_private: true }
    payload[:project] = { key: project } if project
    repo = connection.post(path, payload)
    raise "Repo creation error: #{repo.body['error'].to_s}" unless repo.success?
    repo.body
  end
end
