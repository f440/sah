require "sah"
require 'faraday'
require 'faraday_middleware'

module Sah
  class API
    attr_accessor :config, :conn

    def initialize(config)
      @config = config

      base_url = (config.url).to_s.sub(/#{config.url.path}$/, '')
      @conn = Faraday.new(url: base_url) do |faraday|
        faraday.response :json
        faraday.response :logger if config.verbose
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth config.user, config.password
      end
    end

    def show_branches(project, repository)
      @conn.get do |req|
        req.url @config.url.path + "/rest/api/1.0/projects/#{project}/repos/#{repository}/branches"
      end
    end

    def fork_repository(project, repo, name=nil)
      body = {slug: repo}
      body = body.merge(name: name) if name

      @conn.post do |req|
        req.url @config.url.path + "/rest/api/1.0/projects/#{project}/repos/#{repo}"
        req.headers['Content-Type'] = 'application/json'
        req.body = body.to_json
      end
    end

    def create_repository(project, repo)
      @conn.post do |req|
        req.url @config.url.path + "/rest/api/1.0/projects/#{project}/repos"
        req.headers['Content-Type'] = 'application/json'
        req.body = {name: repo, scmId: "git", forkable: true}.to_json
      end
    end

    def list_project
      @conn.get do |req|
        req.url @config.url.path + "/rest/api/1.0/projects"
        req.params['limit'] = 1000
      end
    end

    def show_project(project)
      @conn.get do |req|
        req.url @config.url.path + "/rest/api/1.0/projects/#{project}"
      end
    end

    def list_user
      @conn.get do |req|
        req.url @config.url.path + "/rest/api/1.0/users"
        req.params['limit'] = 1000
      end
    end

    def show_user(user)
       @conn.get do |req|
        req.url @config.url.path + "/rest/api/1.0/users/#{user}"
      end
    end

    def list_repository(project)
      @conn.get do |req|
        req.url @config.url.path + "/rest/api/1.0/projects/#{project}/repos"
        req.params['limit'] = 1000
      end
    end

    def show_repository(project, repository)
      @conn.get do |req|
        req.url @config.url.path + "/rest/api/1.0/projects/#{project}/repos/#{repository}"
      end
    end

    def create_pull_request(source, target, title="", description="", reviewers=[])
      @conn.post do |req|
        req.url @config.url.path +
          "/rest/api/1.0/projects/#{target[:project]}/repos/#{target[:repository]}/pull-requests"
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          title: title,
          description: description,
          state: "OPEN",
          closed: false,
          fromRef: {
            id: "refs/heads/#{source[:branch]}",
            repository: {
              slug: source[:repository],
              name: nil,
              project: {
                key: source[:project]
              }
            }
          },
          toRef: {
            id: "refs/heads/#{target[:branch]}",
            repository: {
              slug: target[:repository],
              name: nil,
              project: {
                key: target[:project]
              }
            }
          },
          locked: false,
          reviewers: reviewers.map{ |r| { user: { name: r } } }
        }.to_json
      end
    end
  end
end
