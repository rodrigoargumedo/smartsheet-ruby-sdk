require 'plissken'

require 'smartsheet/api/error'

module Smartsheet
  module API
    class ResponseNetClientDecorator
      attr_reader :json_output, :client
      private :json_output, :client

      def initialize(client, json_output: false)
        @json_output = json_output
        @client = client
      end

      def make_request(request)
        parse(client.make_request(request))
      end

      private

      def parse(response)
         if response.success?
           parse_success(response)
         else
           parse_failure(response)
         end
      end

      def parse_success(response)
        if json_output
          response.result.to_json
        elsif response.result.respond_to? :to_snake_keys
          snake_key_hash = response.result.to_snake_keys
          RecursiveOpenStruct.new(snake_key_hash, recurse_over_arrays: true)
        else
          response.result
        end
      end

      def parse_failure(response)
        raise ApiError.new(response)
      end
    end
  end
end