# Implementation courtesy of db-charmer.
class Octoball
  module LogSubscriber
    attr_accessor :current_shard, :current_dbn

    def sql(event)
      shard = event.payload[:connection]&.current_shard
      if shard == ActiveRecord::Base.default_shard
        self.current_shard = nil
        self.current_dbn = nil
      else
        self.current_shard = shard
        self.current_dbn = event
          .payload[:connection]
          .instance_variable_get(:@connection)
          .instance_variable_get(:@current_query_options)[:database]
      end
      super
    end

    private

    def debug(progname = nil, &block)
      conn = current_shard ? color("[Shard: #{current_shard}, db: #{current_dbn}]", ActiveSupport::LogSubscriber::GREEN, true) : ''
      super(conn + progname.to_s, &block)
    end
  end
end

ActiveRecord::LogSubscriber.prepend(Octoball::LogSubscriber)
