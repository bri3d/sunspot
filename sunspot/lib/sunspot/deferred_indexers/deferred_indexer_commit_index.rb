module Sunspot
  module DeferredIndexers
    class DeferredIndexerCommitIndex
      @queue = "DeferredIndexer"
      def self.perform(*args)
        conn = RSolr.connect :url => Sunspot.config.solr.url
        conn.commit
      end
    end
  end
end
