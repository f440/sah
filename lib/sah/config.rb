module Sah
  class Config
    attr_accessor :user, :password, :ssh_url, :base_url

    def initialize(profile)
      @user, @password, @ssh_url, @base_url = nil, nil, nil, nil

      prefix = "sah\.profile\.#{profile}"
      config = %x(git config --get-regex "^#{prefix}")
      config.each_line do |line|
        case line
        when /#{prefix}\.user (.*)$/
          @user = $1
        when /#{prefix}\.password (.*)$/
          @password = $1
        when /#{prefix}\.base-url (.*)$/
          @base_url = $1
        when /#{prefix}\.ssh-url (.*)$/
          @ssh_url = $1
        end
      end

      unless @user && @password && @ssh_url && @base_url
        abort "Invalid profile: #{profile}"
      end
    end
  end
end
