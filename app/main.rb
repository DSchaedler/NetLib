# frozen_string_literal: true

require 'app/net_lib.rb'
require 'app/server.rb'
require 'app/client.rb'

def tick(args)  # rubocop:disable Lint/UnusedMethodArgument
  args.state.port ||= 9001

  args.state.nl_server ||= NLServer.new(port: args.state.port)
  args.state.nl_client ||= NLClient.new

  args.state.nl_server.state = args.state.nl_server.state.merge(first_key: 'First Data')
  args.state.nl_server.state = args.state.nl_server.state.merge(second_key: 'Second Data')
  args.state.nl_server.state = args.state.nl_server.state.merge(time: "#{args.state.tick_count}")

  unless args.state.first_response
    args.state.nl_client.initiate_download(url: "http://localhost:#{args.state.port}/first_key") unless args.state.nl_client.download || args.state.nl_client.response
    args.state.first_response ||= args.state.nl_client.response
    args.state.nl_client.response = nil
  end

  unless args.state.second_response
    args.state.nl_client.initiate_download(url: "http://localhost:#{args.state.port}/second_key") unless args.state.nl_client.download || args.state.nl_client.response
    args.state.second_response ||= args.state.nl_client.response
    args.state.nl_client.response = nil
  end

  args.state.nl_client.initiate_download(url: "http://localhost:#{args.state.port}/time") unless args.state.nl_client.download || args.state.nl_client.response
  args.state.time = args.state.nl_client.response
  args.state.nl_client.response = nil

  args.state.nl_client.tick(args)
  args.state.nl_server.tick(args)
  
  args.outputs.labels << [args.grid.center_x, args.grid.center_y, args.state.first_response, 1]
  args.outputs.labels << [args.grid.center_x, args.grid.center_y - 20, args.state.second_response, 1]
  args.outputs.labels << [args.grid.center_x, args.grid.center_y - 40, args.state.time, 1]
end

def reset
  $gtk.args.state.nl_server = nil
  $gtk.args.state.nl_client = nil
end
