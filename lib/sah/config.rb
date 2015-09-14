module Sah
  class Config
    attr_accessor :user, :password, :url,
      :upstream_fetch_pull_request, :upstream_prevent_push

    def initialize(profile)
      @user, @password, @url = nil, nil, nil
      @upstream_fetch_pull_request = false
      @upstream_prevent_push = false

      profile_prefix = "sah\.profile\.#{profile}"
      config_prefix = "sah\.config"

      %x(git config --get-regex "^sah\.").each_line do |line|
        case line
        when /#{profile_prefix}\.user (.*)$/
          @user = $1
        when /#{profile_prefix}\.password (.*)$/
          @password = $1
        when /#{profile_prefix}\.url (.*)$/
          @url = URI.parse $1
        when /#{config_prefix}\.upstream-fetch-pull-request (.*)$/
          @upstream_fetch_pull_request = ($1 == "true")
        when /#{config_prefix}\.upstream-prevent-push (.*)$/
          @upstream_prevent_push = ($1 == "true")
        end
      end

      unless @user && @password && @url
        abort "Invalid profile: #{profile}"
      end
    end
  end
end
