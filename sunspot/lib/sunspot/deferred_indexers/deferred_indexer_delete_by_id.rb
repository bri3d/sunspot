module Sunspot
  module DeferredIndexers
    class DeferredIndexerDeleteById
      @queue = "DeferredIndexer"
      def self.perform(document_ids_json)
        document_ids = JSON.parse(document_ids_json)
        conn = RSolr.connect :url => Sunspot.config.solr.url
        conn.delete_by_id(document_ids)
      end
    end
  end
end
