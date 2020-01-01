require 'faraday'
require 'faraday_middleware'

class BitBucket
  attr_reader :connection, :username

  def initialize(user, password)
    @username = user
    @connection = Faraday.new 'https://api.bitbucket.org/2.0/' do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.response :raise_error
      conn.adapter Faraday.default_adapter
      conn.basic_auth(user, password)
    end
  end

  def teams
    connection.get('teams?role=admin&pagelen=100').body['values'].map { |t| t['username'] }
  end

  def repos(team)
    team = username if team.nil?
    path = "repositories/#{team}?pagelen=50"
    result = []
    while path
      response = connection.get(path)
      result += response.body['values']
      path = response.body['next']
    end
    result
  end

  def all_repos
    (teams + [username]).map { |team| [repos(team)] }.flatten
  end
end
