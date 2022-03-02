module TokenAuth
  module Authenticator
    extend ActiveSupport::Concern

    included do
      private :authenticate_entity_by_token
      private :ensure_entity_authenticated!
    end

    def authenticate_entity_by_token
      authenticate_with_http_token do |token, options|
        @authentication = TokenAuth::AuthenticationToken.find(token)
        @authentication.entity
      end
    end

    def ensure_entity_authenticated!
      raise Unauthorized.new('Authenitcation failed', :token) unless @current_entity.present?
      @authentication.touch if TokenAuth::renew_authentication_token_on_each_request
    end

    module ClassMethods
      def acts_as_token_authenticator(options = {})
        before_action :authenticate_by_token, options
        before_action :ensure_authenticated!, options
      end

      def skip_acts_as_token_authenticator(options = {})
        skip_before_action :authenticate_by_token, options
        skip_before_action :ensure_authenticated!, options
      end
    end

    def authenticate_by_token
      @current_entity = authenticate_entity_by_token
      @current_session = TokenAuth::Session.new(@authentication)
    end

    def ensure_authenticated!
      ensure_entity_authenticated!
    end

    def current_authenticated_entity
      @current_entity
    end

    def current_session
      @current_session
    end
  end
end

ActionController::Base.send :include, TokenAuth::Authenticator
