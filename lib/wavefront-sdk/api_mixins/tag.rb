# frozen_string_literal: true

module Wavefront
  module Mixin
    #
    # Tagging support.
    #
    # Mix this module into class which supports tags, ensuring there is a
    # valid_id? method to perform ID validation.
    #
    module Tag
      # GET /api/v2/{object}/id/tag
      # Get all tags associated with a specific object.
      #
      # @param id [String] ID of the object
      # @return [Wavefront::Response]
      #
      def tags(id)
        valid_id?(id)
        api.get([id, 'tag'].uri_concat)
      end

      # POST /api/v2/{object}/id/tag
      # Set all tags associated with a specific object.
      #
      # @param id [String] ID of the object
      # @param tags [Array] list of tags to set.
      # @return [Wavefront::Response]
      #
      def tag_set(id, tags)
        valid_id?(id)
        tags = Array(tags)
        tags.each { |t| wf_string?(t) }
        api.post([id, 'tag'].uri_concat, tags.to_json, 'application/json')
      end

      # DELETE /api/v2/{object}/id/tag/tagValue
      # Remove a tag from a specific object.
      #
      # @param id [String] ID of the object
      # @param tag [String] tag to delete
      # @return [Wavefront::Response]
      #
      def tag_delete(id, tag)
        valid_id?(id)
        wf_string?(tag)
        api.delete([id, 'tag', tag].uri_concat)
      end

      # PUT /api/v2/{object}/id/tag/tagValue
      # Add a tag to a specific object.
      #
      # @param id [String] ID of the object
      # @param tag [String] tag to set.
      # @return [Wavefront::Response]
      #
      def tag_add(id, tag)
        valid_id?(id)
        wf_string?(tag)
        api.put([id, 'tag', tag].uri_concat)
      end
    end
  end
end
