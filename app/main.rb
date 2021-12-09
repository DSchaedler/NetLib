# frozen_string_literal: true

require 'app/net_lib.rb'
require 'app/server.rb'
require 'app/client.rb'

def tick(args)  # rubocop:disable Lint/UnusedMethodArgument
  $port ||= 9001

  $server ||= NLServer.new(port: $port)
  $client ||= NLClient.new

  $server.state = $server.state.merge(first_key: 'First Data')
  $server.state = $server.state.merge(second_key: 'Second Data')
  $server.state = $server.state.merge(time: "#{args.state.tick_count}")

  unless $first_response
    $client.initiate_download(url: "http://localhost:#{$port}/first_key") unless $client.download || $client.response
    $first_response ||= $client.response
    $client.response = nil
  end

  unless $second_response
    $client.initiate_download(url: "http://localhost:#{$port}/second_key") unless $client.download || $client.response
    $second_response ||= $client.response
    $client.response = nil
  end

  $client.initiate_download(url: "http://localhost:#{$port}/time") unless $client.download || $client.response
  $time = $client.response
  $client.response = nil

  $client.tick(args)
  $server.tick(args)
  
  args.outputs.labels << [args.grid.center_x, args.grid.center_y, $first_response, 1]
  args.outputs.labels << [args.grid.center_x, args.grid.center_y - 20, $second_response, 1]
  args.outputs.labels << [args.grid.center_x, args.grid.center_y - 40, $time, 1]
end

def reset
  $server = nil
  $client = nil
end
