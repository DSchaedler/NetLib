# frozen_string_literal: true

require 'app/net_lib.rb'
require 'app/server.rb'
require 'app/client.rb'

$gtk.log_level = :warn

def tick(args)
  
  args.state.port ||= 9001

  args.state.server ||= NLServer.new(port: args.state.port)
  args.state.client ||= NLClient.new

  args.state.server.state = args.state.server.state.merge(first_key: 'First Data')
  args.state.server.state = args.state.server.state.merge(second_key: 'Second Data')
  args.state.server.state = args.state.server.state.merge(time: args.state.tick_count.to_s)

  unless args.state.first_response
    args.state.client.get(url: "http://localhost:#{args.state.port}/first_key") unless args.state.client.download || args.state.client.response
    args.state.first_response ||= args.state.client.response
    args.state.client.response = nil
  end

  unless args.state.second_response
    args.state.client.get(url: "http://localhost:#{args.state.port}/second_key") unless args.state.client.download || args.state.client.response
    args.state.second_response ||= args.state.client.response
    args.state.client.response = nil
  end

  args.state.client.get(url: "http://localhost:#{args.state.port}/time") unless args.state.client.download || args.state.client.response
  time = args.state.client.response
  args.state.client.response = nil

  args.state.client.get(url: "http://localhost:#{args.state.port}/") unless args.state.client.download || args.state.client.response
  args.state.client.response = nil

  args.state.client.tick(args)
  args.state.server.tick(args)

  args.outputs.labels << [args.grid.center_x, args.grid.center_y, args.state.first_response, 1, 1]
  args.outputs.labels << [args.grid.center_x, args.grid.center_y - 20, args.state.second_response, 1, 1]
  args.outputs.labels << [args.grid.center_x, args.grid.center_y - 40, time, 1, 1]
  args.outputs.labels << [args.grid.center_x, args.grid.center_y - 60, args.state.client.state, 1, 1]
end

def reset
  $gtk.args.state.server = nil
  $gtk.args.state.client = nil
end
