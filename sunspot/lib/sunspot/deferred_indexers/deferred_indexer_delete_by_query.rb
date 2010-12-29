module Sunspot
  module DeferredIndexers
    class DeferredIndexerDeleteByQuery
      @queue = "DeferredIndexer"
      def self.perform(query)
        conn = RSolr.connect :url => Sunspot.config.solr.url
        conn.delete_by_query(query)
      end
    end
  end
end
