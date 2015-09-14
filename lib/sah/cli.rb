require "sah"
require "thor"
require 'hirb'
require 'hirb-unicode'

module Sah
  class CLI < Thor
    class_option :profile,
      type: :string, default: (ENV["SAH_DEFAULT_PROFILE"] || :default),
      desc: "Set a specific profile"
    class_option :verbose,
      type: :boolean, default: false,
      desc: "Turn on/off verbose mode"

    desc "clone REPOS", "Clone repository"
    long_desc <<-LONG_DESCRIPTION
    sah clone PROJECT/REPO
    \x5> git clone ssh://git@example.com:7999/PROJECT/REPO

    sah clone REPO
    \x5> git clone ssh://git@example.com:7999/~YOUR_NAME/REPO

    sah clone ~USERNAME/REPO
    \x5> git clone ssh://git@example.com:7999/~USERNAME/REPO
    LONG_DESCRIPTION
    def clone(arg)
      repository_slug, project_key = arg.split("/").reverse
      project_key ||= "~#{config.user}"
      res = api.show_repository(project_key, repository_slug)
      if res.body.key? "errors"
        abort res.body["errors"].first["message"]
      end
      repository = res.body
      remote_url =
        repository["links"]["clone"].find{ |e| e["name"] == config.protocol }["href"]
      system "git", "clone", remote_url
    end

    desc "create [PROJECT]", "Create repository"
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
    def create(arg=nil)
      project_key = (arg || "~#{config.user}")
      repository_slug = (
        options[:name] || File.basename(`git rev-parse --show-toplevel`).chomp
      )
      res = api.create_repo(project_key, repository_slug)
      if res.body.key? "errors"
        abort res.body["errors"].first["message"]
      end
      remote_url =
        res.body["links"]["clone"].find{ |e| e["name"] == config.protocol }["href"]
      system "git", "remote", "add", "origin", remote_url
    end

    desc "fork [REPO]", "Fork repository"
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
    def fork(arg=nil)
      if arg
        project_key, repository_slug = arg.split("/")
      else
        remote_url = `git config --get remote.origin.url`.chomp
        remote_url.match %r%/([^/]+)/([^/]+?)(?:\.git)?$%
        project_key, repository_slug = $1, $2
      end
      res = api.fork_repo(project_key, repository_slug, options[:name])
      if res.body.key? "errors"
        abort res.body["errors"].first["message"]
      end
    end

    desc "project [PROJECT]", "Show project information"
    long_desc <<-LONG_DESCRIPTION
    sah project
    \x5# list projects

    sah project PROJECT
    \x5# show project detail
    LONG_DESCRIPTION
    def project(arg=nil)
      if arg
        res = api.show_project(arg)
        if res.body.key? "errors"
          abort res.body["errors"].first["message"]
        end
        project = res.body
        puts Hirb::Helpers::AutoTable.render(project, headers: false)
      else
        res = api.list_project
        if res.body.key? "errors"
          abort res.body["errors"].first["message"]
        end
        projects = res.body["values"].sort_by{|e| e["id"].to_i }
        puts Hirb::Helpers::AutoTable.render(projects, fields: %w(id key name description))
      end
    end

    desc "repository PROJECT[/REPOS]", "Show repository information"
    long_desc <<-LONG_DESCRIPTION
    sah repository PROJECT
    \x5# list repositories

    sah repository PROJECT/REPO
    \x5# show repository detail
    LONG_DESCRIPTION
    def repository(arg)
      project_key, repository_slug = arg.split("/")
      if repository_slug
        res = api.show_repository(project_key, repository_slug)
        if res.body.key? "errors"
          abort res.body["errors"].first["message"]
        end
        repository = res.body
        puts Hirb::Helpers::AutoTable.render(repository, headers: false)
      else
        res = api.list_repository(project_key)
        if res.body.key? "errors"
          abort res.body["errors"].first["message"]
        end
        repositories = (res.body["values"] || []).sort_by{|e| e["id"].to_i }
        puts Hirb::Helpers::AutoTable.render(repositories, fields: %w(id slug name))
      end
    end

    desc "upstream",
      "Show upstream information"
    long_desc <<-LONG_DESCRIPTION
    upstream
    \x5# show upstream information

    upstream --add-remote [--fetch-pull-request] [--prevent-push]
    \x5# add upstream to remote settings
    LONG_DESCRIPTION
    method_option :"add-remote", desc: "Add a upstream repository to remote settings"
    method_option :"fetch-pull-request", desc: "Fetch pull requests"
    method_option :"prevent-push", desc: "Prevent push to upstream"
    def upstream
      remote_url = `git config --get remote.origin.url`.chomp
      remote_url.match %r%/([^/]+)/([^/]+?)(?:\.git)?$%
      project, repository = $1, $2
      res = api.show_repository(project, repository)
      if res.body.key? "errors"
        abort res.body["errors"].first["message"]
      end
      repository = res.body
      upstream_url =
        repository["origin"]["links"]["clone"].find{ |e| e["name"] == config.protocol }["href"]
      if options[:"add-remote"]
        system "git", "remote", "add", "upstream", upstream_url
        if config.upstream_fetch_pull_request || options[:"fetch-pull-request"]
            %x(git config --add remote.upstream.fetch \
                 '+refs/pull-requests/*:refs/remotes/upstream/pull-requests/*')
        end
        if config.upstream_prevent_push || options[:"prevent-push"]
          %x(git remote set-url --push upstream "")
        end
      else
        puts upstream_url
      end
    end

    desc "user [USER]", "Show user information"
    long_desc <<-LONG_DESCRIPTION
    sah user
    \x5# list users

    sah user USER
    \x5# show user detail
    LONG_DESCRIPTION
    def user(arg=nil)
      if arg
        res = api.show_user(arg)
        if res.body.key? "errors"
          abort res.body["errors"].first["message"]
        end
        user = res.body
        puts Hirb::Helpers::AutoTable.render(user, headers: false)
      else
        res = api.list_user
        if res.body.key? "errors"
          abort res.body["errors"].first["message"]
        end
        users = (res.body["values"] || []).sort_by{|e| e["id"].to_i }
        puts Hirb::Helpers::AutoTable.render(users, fields: %w(id slug name displayName))
      end
    end

    desc "version", "Display the version of this command"
    def version
      puts VERSION
    end

    private

    def config
      @config ||= Config.new(options[:profile], verbose: options[:verbose])
    end

    def api
      @api ||= API.new(config)
    end
  end
end
