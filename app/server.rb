# frozen_string_literal: true

NL_S_PRE = '[NetLib][Server] '

# Server Side Code
class NLServer
  attr_accessor :state

  def initialize(port: 9001)
    $gtk.start_server! port: port, enable_in_prod: true
    $gtk.log_debug "#{NL_S_PRE}Initialized on http://localhost:#{port}/"
    $gtk.log_debug "#{NL_S_PRE}Local IP: #{local_ip}"
    $gtk.log_debug "#{NL_S_PRE}External IP: #{external_ip}"

    @state = {}
  end

  def tick(args)
    args.inputs.http_requests.each do |request|
      if request.uri == '/'
        request.respond 200, @state.to_s, { 'X-DRGTK-header' => 'Powered by DragonRuby!' }
      else
        requested_key = request.uri.gsub('/', '').to_sym
        request.respond 200, @state[requested_key].to_s, { 'X-DRGTK-header' => 'Powered by DragonRuby!' }
      end
    end
  end
end
