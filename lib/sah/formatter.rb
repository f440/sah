require "hirb"
require "hirb-unicode"

module Sah
  class Formatter
    def initialize(format: "table")
      @format = case format
                when "table"
                  Format::Hirb
                when "json"
                  Format::Json
                else
                  abort "format must be set to json or table: #{format}"
                end
    end

    def render(*args)
      @format.render(*args)
    end

    module Format
      class Hirb < Hirb::Helpers::AutoTable
      end

      class Json
        def self.render(objects, fields: [], headers: :_)
          if fields.empty?
            objects.to_json
          else
            objects.map do |object|
              object.select{ |k, v| fields.nil? || fields.include?(k) }
            end.to_json
          end
        end
      end
    end
  end
end
