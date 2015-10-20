require "sah"
require "thor"
require "hirb"
require "hirb-unicode"
require "launchy"
require "tempfile"

module Sah
  class CLI < Thor
    class_option :profile,
      type: :string, default: (ENV["SAH_DEFAULT_PROFILE"] || :default),
      desc: "Set a specific profile"
    class_option :verbose,
      type: :boolean, default: false,
      desc: "Turn on/off verbose mode"

    desc "browse [REPO]", "Browse repository"
    long_desc <<-LONG_DESCRIPTION
    sah browse
    \x5# browse current repository

    sah browse REPO
    \x5# browse ~YOUR_NAME/REPO

    sah browse PROJECT/REPO
    \x5# browse PROJECT/REPO

    sah browse --branch
    \x5# browse branch list in current repository

    sah browse --branch BRANCH
    \x5# browse BRANCH in current repository

    sah browse --commit COMMITHASH
    \x5# browse COMMITHASH in current repository

    sah browse --pull-request
    \x5# browse pull request list in current repository

    sah browse --pull-request PULL_REQUEST
    \x5# browse PULL_REQUEST in current repository
    LONG_DESCRIPTION
    method_option :branch, aliases: "-b", desc: "Show branch(es)"
    method_option :commit, aliases: "-c", desc: "Show commit"
    method_option :"pull-request", aliases: "-r", desc: "Show pull request(s)"
    def browse(arg=nil)
      if arg
        repository_slug, project_key = arg.split("/").reverse
        project_key ||= "~#{config.user}"
      else
        remote_url = `git config --get remote.origin.url`.chomp
        remote_url.match %r%/([^/]+)/([^/]+?)(?:\.git)?$%
        project_key, repository_slug = $1, $2
      end
      res = api.show_repository(project_key, repository_slug)
      if res.body.key? "errors"
        abort res.body["errors"].first["message"]
      end

      url = config.url + res.body["link"]["url"]

      if [options[:branch], options[:commit], options[:'pull-request']].compact.count > 1
        abort "Multiple options (--branch, --commit, --pull-request) cannot be handled."
      end

      case options[:branch]
      when nil
        # skip
      when "branch"
        url.path = url.path.sub('/browse', '/branches')
      else
        url.path = url.path.sub('/browse', '/commits')
        url.query =
          URI.encode_www_form([["until", "refs/heads/#{options['branch']}"]])
      end

      case options[:commit]
      when nil
        # skip
      when "commit"
        abort 'You must specify commit hash.'
      else
        url.path = url.path.sub('/browse', "/commits/#{options['commit']}")
      end

      case options[:"pull-request"]
      when nil
        # skip
      when "pull-request"
        url.path = url.path.sub('/browse', "/pull-requests")
      else
        url.path = url.path.sub('/browse', "/pull-requests/#{options[:'pull-request']}/overview")
      end

      Launchy.open(url, debug: config.verbose)
    end

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
      res = api.create_repository(project_key, repository_slug)
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
      res = api.fork_repository(project_key, repository_slug, options[:name])
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

    desc "pull-request", "Create pull request"
    map %w(pr pull-request) => "pull_request"
    long_desc <<-LONG_DESCRIPTION
    sah pull-request
    \x5# create pull-request to upstream repository's default branch
    \x5# open $EDITOR to edit title and body

    \x5sah pull-request [--source,-s PROJECT/REPOSITORY:BRANCH
    \x5                 [--target,-t PROJECT/REPOSITORY:BRANCH
    \x5                 [--message,-m MESSAGE]
    \x5                 [--reviewer,-r REVIEWER1 REVIEWER2 ...]
    LONG_DESCRIPTION
    method_option :source, aliases: "-s", desc: "Set source project/repository:branch"
    method_option :target, aliases: "-t", desc: "Set target project/repository:branch"
    method_option :title, desc: "Set title"
    method_option :description, desc: "Set description"
    method_option :reviewer,
      aliases: "-r", type: :array, desc: "Set reviwer(s)"
    def pull_request
      source_project, source_repository, source_branch = nil, nil, nil
      if options[:source]
        m = options[:source].match(%r{^([^/:]+)/([^/:]+):([^:]+)$})
        if m.nil?
          abort "Invalid format: --source #{options[:source]}"
        end
        source_project, source_repository, source_branch = $1, $2, $3
      else
        remote_url = `git config --get remote.origin.url`.chomp
        remote_url.match %r%/([^/]+)/([^/]+?)(?:\.git)?$%
        source_project, source_repository = $1, $2
        source_branch = current_branch
      end
      source = {project: source_project, repository: source_repository,
                branch: source_branch}

      target_project, target_repository, target_branch = nil, nil, nil
      if options[:target]
        m = options[:target].match(%r{^([^/:]+)/([^/:]+):([^:]+)$})
        if m.nil?
          abort "Invalid format: --target #{options[:target]}"
        end
        target_project, target_repository, target_branch = $1, $2, $3
      else
        upstream = upstream_repository
        target_project = upstream["origin"]["project"]["key"]
        target_repository = upstream["origin"]["slug"]
        res = api.show_branches(target_project, target_repository)
        if res.body.key? "errors"
          abort res.body["errors"].first["message"]
        end
        branches = res.body
        target_branch = branches["values"].find{|b| b["isDefault"] }["displayId"]
      end
      target = {project: target_project, repository: target_repository,
                branch: target_branch}

      puts "%s/%s:%s => %s/%s:%s" % [
        source[:project], source[:repository], source[:branch],
        target[:project], target[:repository], target[:branch],
      ]

      title = options[:title] || (
        puts "Edit title... (press enter key)"
        STDIN.gets
        open_editor.strip
      )
      description = options[:description] || (
        puts "Edit description... (press enter key)"
        STDIN.gets
        open_editor.strip
      )
      reviewers = options[:reviewer] || []

      res = api.create_pull_request source, target, title, description, reviewers
      if res.body.key? "errors"
        abort res.body["errors"].first["message"]
      end
      puts res.body["links"]["self"].first["href"]
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

    upstream --add-remote [--fetch-pull-request] [--prevent-push] [--remote-name=REMOTE-NAME]
    \x5# add upstream to remote settings
    LONG_DESCRIPTION
    method_option :"add-remote", desc: "Add a upstream repository to remote settings"
    method_option :"fetch-pull-request", desc: "Fetch pull requests"
    method_option :"prevent-push", desc: "Prevent push to upstream"
    method_option :"remote-name", type: :string, default: "", desc: "Specify a remote name of upstream"
    def upstream
      upstream_url =
        upstream_repository["origin"]["links"]["clone"].find{ |e| e["name"] == config.protocol }["href"]

      if options[:"add-remote"]
        remote_name = options["remote-name"]
        remote_name = config.upstream_remote_name if remote_name.nil? || remote_name.empty?
        system "git", "remote", "add", remote_name, upstream_url
        if config.upstream_fetch_pull_request || options[:"fetch-pull-request"]
            %x(git config --add remote.#{remote_name}.fetch \
                 '+refs/pull-requests/*:refs/remotes/#{remote_name}/pull-requests/*')
        end
        if config.upstream_prevent_push || options[:"prevent-push"]
          %x(git remote set-url --push #{remote_name} "")
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

    def open_editor
      tmp = Tempfile.new('sah')
      editor = ENV['GIT_EDITOR'] || ENV['EDITOR'] || 'vi'
      system(editor, tmp.path)
      File.open(tmp.path).read
    end

    def current_branch
      %x(git rev-parse --abbrev-ref HEAD).chomp
    end

    def upstream_repository
      remote_url = `git config --get remote.origin.url`.chomp
      remote_url.match %r%/([^/]+)/([^/]+?)(?:\.git)?$%
      project, repository = $1, $2

      res = api.show_repository(project, repository)
      if res.body.key? "errors"
        abort res.body["errors"].first["message"]
      end

      repository = res.body
      unless repository.key? "origin"
        abort "Upstream repos does not exist."
      end

      repository
    end
  end
end
