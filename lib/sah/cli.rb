require "sah"
require "thor"
require 'faraday'
require 'faraday_middleware'
require 'hirb'
require 'hirb-unicode'

module Sah
  class API
    attr_accessor :conn

    def initialize(config)
      @conn = Faraday.new(url: config.base_url) do |faraday|
        faraday.response :json
        # faraday.response :logger
        faraday.adapter Faraday.default_adapter
        faraday.basic_auth config.user, config.password
      end
    end

    def fork_repo(project, repo, name=nil)
      body = {slug: repo}
      body = body.merge(name: name) if name

      res = @conn.post do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos/#{repo}"
        req.headers['Content-Type'] = 'application/json'
        req.body = body.to_json
      end
      if res.status != 201
        puts res.body["errors"].first["message"]
      end
    end

    def create_repo(project, repo)
      res = @conn.post do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos"
        req.headers['Content-Type'] = 'application/json'
        req.body = {name: repo, scmId: "git", forkable: true}.to_json
      end
      if res.status != 201
        puts res.body["errors"].first["message"]
      end
    end

    def list_project
      res = @conn.get do |req|
        req.url "/rest/api/1.0/projects"
        req.params['limit'] = 1000
      end
      if res.status != 200
        puts res.body["errors"].first["message"]
      end
      res.body["values"].sort_by{|e| e["id"].to_i }
    end

    def show_project(project)
      res = @conn.get do |req|
        req.url "/rest/api/1.0/projects/#{project}"
      end
      if res.status != 200
        puts res.body["errors"].first["message"]
      end
      res.body
    end

    def list_user
      res = @conn.get do |req|
        req.url "/rest/api/1.0/users"
        req.params['limit'] = 1000
      end
      if res.status != 200
        puts res.body["errors"].first["message"]
      end
      users = res.body["values"].sort_by{|e| e["id"].to_i }
    end

    def show_user(user)
      res = @conn.get do |req|
        req.url "/rest/api/1.0/users/#{user}"
      end
      if res.status != 200
        puts res.body["errors"].first["message"]
      end
      res.body
    end

    def list_repository(project)
      res = @conn.get do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos"
        req.params['limit'] = 1000
      end
      if res.status != 200
        puts res.body["errors"].first["message"]
      end
      repositories = (res.body["values"] || []).sort_by{|e| e["id"].to_i }
    end

    def show_repository(project, repository)
      res = @conn.get do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos/#{repository}"
      end
      if res.status != 200
        puts res.body["errors"].first["message"]
      end
      res.body
    end
  end

  class CLI < Thor
    class_option :profile,
      type: :string, default: (ENV["SAH_DEFAULT_PROFILE"] || :default),
      desc: "Set a specific profile"

    desc "clone REPOS", "Clone repository"
    long_desc <<-LONG_DESCRIPTION
    sah clone PROJECT/REPO
    \x5> git clone ssh://git@example.com:7999/project/REPO

    sah clone REPO
    \x5> git clone ssh://git@example.com:7999/~YOUR_NAME/REPO

    sah clone ~USERNAME/REPO
    \x5> git clone ssh://git@example.com:7999/~USERNAME/REPO
    LONG_DESCRIPTION
    def clone(repos)
      remote_url = case repos
                   when %r%^[^/]+/[^/]+$%
                     "#{config.ssh_url}/#{repos}"
                   when %r%^[^/]+$%
                     "#{config.ssh_url}/~#{config.user}/#{repos}"
                   else
                     repos
                   end
      system "git", "clone", remote_url
    end

    desc "create [PROJECT] [--name REPO_NAME]", "Create repository"
    long_desc <<-LONG_DESCRIPTION
    sah create
    \x5# create repository
    \x5# repository name is same as the current repository

    sah create --name REPO
    \x5# create repository at ~YOUR_NAME/REPO

    sah create PROJECT
    \x5# create repository at PROJECT
    \x5# repository name is same as the current repository
    LONG_DESCRIPTION
    method_option :name, aliases: "-n", desc: "Set repository name"
    def create(project=nil)
      project ||= "~#{config.user}"
      repo = (
        options[:name] || File.basename(`git rev-parse --show-toplevel`).chomp
      )
      api.create_repo(project, repo)
    end

    desc "fork [REPO] [--name REPO_NAME]", "Fork repository"
    long_desc <<-LONG_DESCRIPTION
    sah fork
    \x5# fork from current repository to ~YOUR_NAME/REPO
    \x5# repository name is same as the origin's one

    sah fork --name MY_FORKED_REPO
    \x5# fork from current repository to ~YOUR_NAME/MY_FORKED_REPO

    sah fork PROJECT/REPO
    \x5# fork from PROJECT/REPO to ~YOUR_NAME/REPO

    sah fork ~USERNAME/REPO
    \x5# fork from ~USERNAME/REPO to ~YOUR_NAME/REPO
    LONG_DESCRIPTION
    method_option :name, aliases: "-n", desc: "Set repository name"
    def fork(repos=nil)
      if repos
        project, repo = repos.split("/")
      else
        remote_url = `git config --get remote.origin.url`
        unless remote_url.match %r%^#{config.ssh_url}/([^/]+)/([^/]+).git$%
          abort "Missing: #{remote_url}"
        end
        project, repo = $1, $2
      end
      api.fork_repo(project, repo, options[:name])
    end

    desc "project [PROJECT]", "Show project information"
    long_desc <<-LONG_DESCRIPTION
    sah project
    \x5# list projects

    sah project PROJECT
    \x5# show project detail
    LONG_DESCRIPTION
    def project(project=nil)
      if project.nil?
        projects = api.list_project
        puts Hirb::Helpers::AutoTable.render(projects, fields: %w(id key name description))
      else
        project = api.show_project(project)
        puts Hirb::Helpers::AutoTable.render(project, headers: false)
      end
    end

    desc "repository PROJECT[/REPOS]", "Show repository information"
    long_desc <<-LONG_DESCRIPTION
    sah repository PROJECT
    \x5# list repositories

    sah repository PROJECT/REPO
    \x5# show repository detail
    LONG_DESCRIPTION
    def repository(repo)
      project, repository = repo.split("/")
      if repository.nil?
        repositories = api.list_repository(project)
        puts Hirb::Helpers::AutoTable.render(repositories, fields: %w(id slug name))
      else
        repository = api.show_repository(project, repository)
        puts Hirb::Helpers::AutoTable.render(repository, headers: false)
      end
    end

    desc "user [USER]", "Show user information"
    long_desc <<-LONG_DESCRIPTION
    sah user
    \x5# list users

    sah user USER
    \x5# show user detail
    LONG_DESCRIPTION
    def user(user=nil)
      if user.nil?
        users = api.list_user
        puts Hirb::Helpers::AutoTable.render(users, fields: %w(id slug name displayName))
      else
        user = api.show_user(user)
        puts Hirb::Helpers::AutoTable.render(user, headers: false)
      end
    end

    desc "version", "Display the version of this command"
    def version
      puts VERSION
    end

    private

    def config
      @config ||= Config.new(options[:profile])
    end

    def api
      @api ||= API.new(config)
    end
  end
end
