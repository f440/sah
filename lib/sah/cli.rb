require "sah"
require "thor"

module Sah
  class Config
    attr_accessor :user, :password, :url

    def initialize(profile)
      @user, @password, @url = nil, nil, nil

      config = %x(git config --get-regex "^sah\.#{profile}")
      config.each_line do |line|
        case line
        when /sah\.#{profile}\.user (.*)$/
          @user = $1
        when /sah\.#{profile}\.password (.*)$/
          @password = $1
        when /sah\.#{profile}\.url (.*)$/
          @url = $1
        end
      end
      abort "Profile is not set" unless (@user || @password || @url)
    end
  end

  class CLI < Thor
    class_option :profile, type: :string, default: (ENV["SAH_DEFAULT_PROFILE"] || :default)

    desc "clone REPOS", "clone repository"
    long_desc <<-LONG_DESCRIPTION
    sah clone project/repos
    \x5#=> git clone ssh://git@example.com:7999/project/repos

    sah clone repos
    \x5#=> git clone ssh://git@example.com:7999/~me/repos

    sah clone ~user/repos
    \x5#=> git clone ssh://git@example.com:7999/~user/repos
    LONG_DESCRIPTION
    def clone(repos)
      config = Config.new(options[:profile])
      puts config.user; exit
      remote_url = ""
      case repos
      when %r%^[^/]+/[^/]+$% # Specific project's repository
        remote_url = "#{config.url}/#{repos}"
      when %r%^[^/]+$% # Current user's repository
        remote_url = "#{config.url}/~#{config.user}/#{repos}"
      when /^~/ # Specific user's repository
        remote_url = "#{config.url}/#{repos}"
      else
        remote_url = repos
      end
      system "git", "clone", remote_url
    end

    desc "version", "current version"
    def version
      puts VERSION
    end
  end
end
