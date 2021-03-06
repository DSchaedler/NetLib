# frozen_string_literal: true

NL_C_PRE = '[NetLib][Client] '

# Client Side Code
class NLClient
  attr_accessor :download, :percent, :response, :state

  def initialize
    $gtk.log_debug "#{NL_C_PRE}Initialized"
    @download = nil
    @percent = nil
    @response = nil

    @state = {}
  end

  def tick(args) # rubocop:disable Lint/UnusedMethodArgument
    return if @download.nil?

    if @download[:complete] && @download[:http_response_code].between?(200, 299)
      #$gtk.log_debug "#{NL_C_PRE}Download Complete."
      if @download[:response_data][0] == '{'
        @state = eval @download[:response_data]
      else
        @response = @download[:response_data]
      end
      @download = nil
    elsif @download[:http_response_code].zero?
      done = @download[:response_read]
      total = @download[:response_total]
      if total != 0
        percent = (done / total).to_f
        $gkt.log_debug "#{NL_C_PRE}Download Stalled: #{percent}%"
      end
    else
      $gtk.log_error "#{NL_C_PRE}HTTP Error: #{@download[:http_response_code]}"
      @response = "HTTP Error: #{@download[:http_response_code]}"
      @download = nil
    end
  end

  def get(url:)
    @download = $gtk.http_get url, extra_headers = [] # rubocop:disable Lint/UselessAssignment
  end
end
