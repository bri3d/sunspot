module Sunspot
  module DeferredIndexers
    class DeferredIndexerAddDocuments
      @queue = "DeferredIndexer"
      def self.perform(documents_json)
        conn = RSolr.connect :url => Sunspot.config.solr.url
        documents = JSON.parse(documents_json).map do |d|
          doc = RSolr::Message::Document.new
          doc.attrs = d["attrs"]
          d["fields"].each do |f|
            options = {}
            options[:boost] = f["attrs"]["boost"] if f["attrs"].key?("boost")
            doc.add_field(f["attrs"]["name"], f["value"], options)
          end
          doc
        end
        conn.add(documents)
      end
    end
  end
end
