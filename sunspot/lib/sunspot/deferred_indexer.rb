module Sunspot
  # 
  # This class presents a service for adding, updating, and removing data
  # from the Solr index. An Indexer instance is associated with a particular
  # setup, and thus is capable of indexing instances of a certain class (and its
  # subclasses).
  #
  # This DeferredIndexer provides deferred (queued) indexing via Resque.
  # Thus, updates will be FIFO and will occur in the same way they would normally
  # with the exception that there are no guarentees as to when updates will occur
  # and that errors are handled offline rather than in-application.
  # This allows indexing without blocking a user-facing task, crucial when a large
  # index makes addition and deletion take a significant time.
  # Indexing is deferred here (at the lowest level) to provide the widest range 
  # of compatibility, including compatibility with sunspot_rails and its automated
  # indexing functionality.

  # The DeferredIndexer class is the "client" - it places indexing operations onto
  # the message queue.

  class DeferredIndexer #:nodoc:
    include RSolr::Char

    def initialize(connection)
      @connection = connection
    end

    # 
    # Construct a representation of the model for indexing and send it to the
    # connection for indexing
    #
    # ==== Parameters
    #
    # model<Object>:: the model to index
    #
    def add(model)
      documents = Util.Array(model).map { |m| prepare(m) }
      if @batch.nil?
        add_documents(documents)
      else
        @batch.concat(documents)
      end
    end

    # 
    # Remove the given model from the Solr index
    #
    def remove(*models)
      Resque.enqueue(DeferredIndexers::DeferredIndexerDeleteById, models.map { |model| Adapters::InstanceAdapter.adapt(model).index_id }.to_json)
    end

    # 
    # Remove the model from the Solr index by specifying the class and ID
    #
    def remove_by_id(class_name, *ids)
      Resque.enqueue(DeferredIndexers::DeferredIndexerDeleteById, ids.map { |id| Adapters::InstanceAdapter.index_id_for(class_name, id) }.to_json)
    end

    # 
    # Delete all documents of the class indexed by this indexer from Solr.
    #
    def remove_all(clazz = nil)
      if clazz
        Resque.enqueue(DeferredIndexers::DeferredIndexerDeleteByQuery, "type:#{escape(clazz.name)}")
        #@connection.delete_by_query("type:#{escape(clazz.name)}")
      else
        Resque.enqueue(DeferredIndexers::DeferredIndexerDeleteByQuery, "*:*")
        #@connection.delete_by_query("*:*")
      end
    end

    # 
    # Remove all documents that match the scope given in the Query
    #
    def remove_by_scope(scope)
      Resque.enqueue(DeferredIndexers::DeferredIndexerDeleteByQuery, scope.to_boolean_phrase)
      #@connection.delete_by_query(scope.to_boolean_phrase)
    end

    # 
    # Start batch processing
    #
    def start_batch
      @batch = []
    end

    #
    # Write batch out to Solr and clear it
    #
    def flush_batch
      add_documents(@batch)
      @batch = nil
    end

    private

    # 
    # Convert documents into hash of indexed properties
    #
    def prepare(model)
      document = document_for(model)
      setup = setup_for(model)
      if boost = setup.document_boost_for(model)
        document.attrs[:boost] = boost
      end
      setup.all_field_factories.each do |field_factory|
        field_factory.populate_document(document, model)
      end
      document
    end

    def add_documents(documents)
      Resque.enqueue(DeferredIndexers::DeferredIndexerAddDocuments, documents.to_json)
      #@connection.add(documents)
    end

    # 
    # All indexed documents index and store the +id+ and +type+ fields.
    # This method constructs the document hash containing those key-value
    # pairs.
    #
    def document_for(model)
      RSolr::Message::Document.new(
        :id => Adapters::InstanceAdapter.adapt(model).index_id,
        :type => Util.superclasses_for(model.class).map { |clazz| clazz.name }
      )
    end

    # 
    # Get the Setup object for the given object's class.
    #
    # ==== Parameters
    #
    # object<Object>:: The object whose setup is to be retrieved
    #
    # ==== Returns
    #
    # Sunspot::Setup:: The setup for the object's class
    #
    def setup_for(object)
      Setup.for(object.class) || raise(NoSetupError, "Sunspot is not configured for #{object.class.inspect}")
    end
  end
end
