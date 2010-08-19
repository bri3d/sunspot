module Sunspot
  # 
  #   This module contains the deferred indexing jobs.
  #
  module DeferredIndexers

    autoload(
      :DeferredIndexerDeleteById,
      File.join(
        File.dirname(__FILE__),
        'deferred_indexers',
        'deferred_indexer_delete_by_id'
      )
    )
    autoload(
      :DeferredIndexerDeleteByQuery,
      File.join(
        File.dirname(__FILE__),
        'deferred_indexers',
        'deferred_indexer_delete_by_query'
      )
    )
    autoload(
      :DeferredIndexerAddDocuments,
      File.join(
        File.dirname(__FILE__),
        'deferred_indexers',
        'deferred_indexer_add_documents'
      )
    )
    autoload(
      :DeferredIndexerCommitIndex,
      File.join(
        File.dirname(__FILE__),
        'deferred_indexers',
        'deferred_indexer_commit_index'
      )
    )
  end
end
