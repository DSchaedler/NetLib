# frozen_string_literal: true

NL_C_PRE = '[NetLib][Client] '

class NLClient
  attr_accessor :download, :percent, :response
  def initialize
    $gtk.log_debug "#{NL_C_PRE}Initialized"
    @download = nil
    @percent = nil
    @response = nil
  end

  def tick(args)
    if !@download.nil?
      if @download[:complete] && @download[:http_response_code].between?(200, 299)
        $gtk.log_debug "#{NL_C_PRE}Download Complete."
        @response = @download[:response_data]
        @download = nil
      else
        if @download[:http_response_code] == 0
          done = @download[:response_read]
          total = @download[:response_total]
          if total != 0
            percent = done.to_f / total.to_f
            $gkt.log_debug "#{NL_C_PRE} download stalled: #{percent}%"
          end
        else
          $gtk.log_error "#{NL_C_PRE}HTTP Error: #{@download[:http_response_code]}"
          @response = "HTTP Error: #{@download[:http_response_code]}"
          @download = nil
        end
      end
    end
  end

  def initiate_download(url:)
    @download = $gtk.http_get url, extra_headers = []
  end
end
