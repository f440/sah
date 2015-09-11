module Sah
  class Config
    attr_accessor :user, :password, :url

    def initialize(profile)
      @user, @password, @url = nil, nil, nil

      prefix = "sah\.profile\.#{profile}"
      config = %x(git config --get-regex "^#{prefix}")
      config.each_line do |line|
        case line
        when /#{prefix}\.user (.*)$/
          @user = $1
        when /#{prefix}\.password (.*)$/
          @password = $1
        when /#{prefix}\.url (.*)$/
          @url = $1
        end
      end

      unless @user && @password && @url
        abort "Invalid profile: #{profile}"
      end
    end
  end
end
