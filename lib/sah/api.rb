require "sah"
require 'faraday'
require 'faraday_middleware'

module Sah
  class API
    attr_accessor :conn

    def initialize(config)
      @conn = Faraday.new(url: config.url) do |faraday|
        faraday.response :json
        # faraday.response :logger
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth config.user, config.password
      end
    end

    def fork_repo(project, repo, name=nil)
      body = {slug: repo}
      body = body.merge(name: name) if name

      @conn.post do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos/#{repo}"
        req.headers['Content-Type'] = 'application/json'
        req.body = body.to_json
      end
    end

    def create_repo(project, repo)
      @conn.post do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos"
        req.headers['Content-Type'] = 'application/json'
        req.body = {name: repo, scmId: "git", forkable: true}.to_json
      end
    end

    def list_project
       @conn.get do |req|
        req.url "/rest/api/1.0/projects"
        req.params['limit'] = 1000
      end
    end

    def show_project(project)
      @conn.get do |req|
        req.url "/rest/api/1.0/projects/#{project}"
      end
    end

    def list_user
      @conn.get do |req|
        req.url "/rest/api/1.0/users"
        req.params['limit'] = 1000
      end
    end

    def show_user(user)
       @conn.get do |req|
        req.url "/rest/api/1.0/users/#{user}"
      end
    end

    def list_repository(project)
      @conn.get do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos"
        req.params['limit'] = 1000
      end
    end

    def show_repository(project, repository)
      @conn.get do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos/#{repository}"
      end
    end
  end
end
