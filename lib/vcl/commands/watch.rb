module VCL
  class CLI < Thor
    desc "watch", "Watch live stats on a service"
    option :service
    def watch
      service = options[:service]
      service ||= VCL::Utils.parse_directory

      ts = false
      while true
        data = VCL::Fetcher.api_request(:get,"/rt/v1/channel/#{service}/ts/#{ts ? ts : 'h/limit/120'}", :endpoint => :app)
        
        unless data["Data"].length > 0
          say("No data to display!")
          abort
        end

        agg = data["Data"][0]["aggregated"]

        rps = agg["requests"]
        # gbps
        bw = ((agg["resp_header_bytes"] + agg["resp_body_bytes"]).to_f * 8.0) / 1000000000.0
        hit_rate = (1.0 - ((agg["miss"] - agg["shield"]).to_f / agg["requests"].to_f)) * 100.0
        passes = agg["pass"]
        miss_time = ((agg["miss_time"] / agg["miss"]) * 1000).round(0)
        synth = agg["synth"]
        errors = agg["errors"]

        $stdout.flush
        print " #{rps} req/s | #{bw.round(3)}gb/s | #{hit_rate.round(2)}% Hit Ratio | #{passes} passes/s | #{synth} synths/s | #{miss_time}ms miss time | #{errors} errors/s   \r"

        ts = data["Timestamp"]
      end
    end
  end
end
