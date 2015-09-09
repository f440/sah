require "sah"
require "thor"
require 'faraday'
require 'faraday_middleware'

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

    def fork(project, repo)
      res = @conn.post do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos/#{repo}"
        req.headers['Content-Type'] = 'application/json'
        req.body = {slug: repo}.to_json
      end
      if res.status != 201
        puts res.body["errors"].first["message"]
      end
    end

    def create(project, repo)
      res = @conn.post do |req|
        req.url "/rest/api/1.0/projects/#{project}/repos"
        req.headers['Content-Type'] = 'application/json'
        req.body = {name: repo, scmId: "git", forkable: true}.to_json
      end
      if res.status != 201
        puts res.body["errors"].first["message"]
      end
    end
  end

  class Util
    def self.complete_url(repos, config)
      case repos
      when %r%^[^/]+/[^/]+$%
        "#{config.ssh_url}/#{repos}"
      when %r%^[^/]+$%
        "#{config.ssh_url}/~#{config.user}/#{repos}"
      else
        repos
      end
    end
  end

  class Remote < Thor
    desc "add NAME PROJECT_OR_USER/REPOS", 'remote add'
    long_desc <<-LONG_DESCRIPTION
    sah remote add remote-name project/repos
    \x5> git remote add remote-name $STASH_URL/project/repos

    sah remote add remote-name ~user/repos
    \x5> git remote add remote-name $STASH_URL/~user/repos

    sah remote add remote-name repos
    \x5> git remote add remote-name $STASH_URL/~my/repos
    LONG_DESCRIPTION
    def add(name, repos)
      config = Config.new(options[:profile])
      remote_url = Util.complete_url(repos, config)
      system "git", "remote", "add", name, remote_url
    end
  end

  class CLI < Thor
    class_option :profile,
      type: :string, default: (ENV["SAH_DEFAULT_PROFILE"] || :default),
      desc: "Set a specific profile"
    register(Remote, 'remote', 'remote [COMMAND]', 'Manage remote repositories')

    desc "fork [REPOS]", "Fork repository"
    long_desc <<-LONG_DESCRIPTION
    sah fork
    \x5# fork from current repository to my/repo

    sah fork project/repo
    \x5# fork from project/repo to my/repo

    sah fork ~user/repo
    \x5# fork from ~user/repo to my/repo
    LONG_DESCRIPTION
    def fork(repos=nil)
      config = Config.new(options[:profile])
      api = API.new(config)

      if repos
        project, repo = repos.split("/")
      else
        remote_url = `git config --get remote.origin.url`
        unless remote_url.match %r%^#{config.ssh_url}/([^/]+)/([^/]+).git$%
          abort "Missing: #{remote_url}"
        end
        project, repo = $1, $2
      end
      api.fork(project, repo)
    end

    desc "clone REPOS", "Clone repository"
    long_desc <<-LONG_DESCRIPTION
    sah clone project/repos
    \x5> git clone ssh://git@example.com:7999/project/repos

    sah clone repos
    \x5> git clone ssh://git@example.com:7999/~me/repos

    sah clone ~user/repos
    \x5> git clone ssh://git@example.com:7999/~user/repos
    LONG_DESCRIPTION
    def clone(repos)
      config = Config.new(options[:profile])

      system "git", "clone", Util.complete_url(repos, config)
    end

    desc "create REPOS", "Create repository"
    long_desc <<-LONG_DESCRIPTION
    sah create [name]
    \x5# create new repository

    sah create project/repos
    \x5> create new repository in specific project
    LONG_DESCRIPTION
    def create(repos=nil)
      config = Config.new(options[:profile])
      api = API.new(config)

      if repos
        repo, project = repos.split("/").reverse
      else
        repo = File.basename `git rev-parse --show-toplevel`.chomp
        project = nil
      end
      project ||= "~#{config.user}"
      api.create(project, repo)
    end

    desc "version", "Display the version of this command"
    def version
      puts VERSION
    end
  end
end
