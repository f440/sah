module Sah
  class Config
    attr_accessor :user, :password, :ssh_url, :base_url

    def initialize(profile)
      @user, @password, @ssh_url, @base_url = nil, nil, nil, nil

      config = %x(git config --get-regex "^sah\.#{profile}")
      config.each_line do |line|
        case line
        when /sah\.#{profile}\.user (.*)$/
          @user = $1
        when /sah\.#{profile}\.password (.*)$/
          @password = $1
        when /sah\.#{profile}\.base-url (.*)$/
          @base_url = $1
        when /sah\.#{profile}\.ssh-url (.*)$/
          @ssh_url = $1
        end
      end

      unless @user && @password && @ssh_url && @base_url
        abort "Invalid profile: #{profile}"
      end
    end
  end
end
