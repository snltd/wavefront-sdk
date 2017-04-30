require_relative './base'

module Wavefront
  #
  # Manage and query Wavefront external links.
  #
  class ExternalLink < Wavefront::Base
    api_base = '/extlink'

    # Returns a list of all external links in your account
    #
    # @param offset [Int] link at which the list begins
    # @param limit [Int] the number of link to return
    #
    def list(offset = 0, limit = 100)
      api_get('', { offset: offset, limit: limit }.to_qs)
    end

    # Create an external link.
    #
    # @param name [String] a plaintext name for the link
    # @param template [String] a mustache template for the link target
    # @param description [String] a plaintext description of the link
    # @return [Hash]
    #
    def create(name, template, description = '')
      wf_string?(name)
      wf_string?(description)
      wf_link_template?(template)
      api_post('', { name:        name,
                     template:    template,
                     description: description }, 'application/json')
    end

    # presents everything the server knows about the given link
    #
    # @param id [String] ID of the limnk
    # @return [Hash]
    #
    def describe(id)
      wf_link_id?(id)
      api_get(id)
    end

    # Delete the link agent. Deleting a link it to 'trash', from where
    # it can be restored with an #undelete operation. Deleting a link in
    # 'trash' removes it for ever.
    #
    # @param id [String] ID of the link
    # @return [Hash]
    #
    def delete(id)
      wf_link_id?(id)
      api_delete(id)
    end

    # Move a link from 'trash' back into active service.
    #
    # @param id [String] ID of the link
    # @return [Hash]
    #
    def undelete(id)
      wf_link_id?(id)
      api_post([id, 'undelete'].uri_concat)
    end

    # A generic function to change properties of a link.
    #
    # @param id [String] ID of the link
    # @param payload [Hash] a key: value hash, where the key is the
    #   property to change and the value is its desired value. If the
    #   payload contains :name, :template, or :description fields, they
    #   are validated.
    # @return [Hash]
    #
    def update(id, payload)
      wf_string?(payload[:name]) if payload.key?(:name)
      wf_string?(payload[:description]) if payload.key?(:description)
      wf_link_template?(payload[:template]) if payload.key?(:template)
      wf_link_id?(id)
      api_put(id, payload)
    end
  end
end
