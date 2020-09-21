# frozen_string_literal: true

module Wavefront
  module Mixin
    #
    # Things needed by User and UserGroup classes
    #
    module User
      # Validate a list of users.
      # @param list [Array[String]] list of user IDs
      # @raise Wavefront::Exception::InvalidUser
      #
      def validate_user_list(list)
        raise ArgumentError unless list.is_a?(Array)

        list.each { |id| wf_user_id?(id) }
      end

      # Validate a list of user groups
      # @param list [Array[String]] list of user group IDs
      # @raise Wavefront::Exception::InvalidUserGroup
      #
      def validate_usergroup_list(list)
        raise ArgumentError unless list.is_a?(Array)

        list.each { |id| wf_usergroup_id?(id) }
      end

      # Validate a list of accounts.
      # @param list [Array[String]] list of account IDs
      # @raise Wavefront::Exception::InvalidAccount
      #
      def validate_account_list(list)
        raise ArgumentError unless list.is_a?(Array)

        list.each { |id| wf_account_id?(id) }
      end

      # Validate a list of roles
      # @param list [Array[String]] list of role IDs
      # @raise Wavefront::Exception::InvalidRole
      #
      def validate_role_list(list)
        raise ArgumentError unless list.is_a?(Array)

        list.each { |id| wf_role_id?(id) }
      end
    end
  end
end
