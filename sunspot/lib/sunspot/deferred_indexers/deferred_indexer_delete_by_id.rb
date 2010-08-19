module Sunspot
  module DeferredIndexers
    class DeferredIndexerDeleteById
      @queue = "DeferredIndexer"
      def self.perform(document_id)
        conn = RSolr.connect :url => Sunspot.config.solr.url
        conn.delete_by_id(document_id)
      end
    end
  end
end
