module TokenAuth
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      before_save :hash_password
    end

    module ClassMethods
      def authenticate(args)
        validate_credentials!(args)

        begin
          entity = find_by(*perform_conditions(args))
          entity.create_authentication

        rescue Exception => exp
          logger.debug exp
          raise Unauthorized.new('Authenitcation failed', :credentials)
        end
      end

      def generate_hash(password)
        Digest::SHA2.hexdigest(Digest::SHA2.hexdigest(TokenAuth::salt + password.to_s) +
                                TokenAuth::salt.reverse)
      end

      def unauthenticate(exchange_token)
        TokenAuth::ExchangeToken.find(exchange_token).destroy_token
      end

      private

      def credentials(*args)
        class_variable_set(:@@credentials, args)
      end

      def perform_conditions(args)
        conditions, params =
          class_variable_get(:@@credentials).zip(args).map do |credential, value|
            case credential
            when :password then ["#{credential} = ?", generate_hash(value)]
            when :email then ["lower(email) = ?", value.downcase]
            else ["#{credential} = ?", value]
            end
          end.transpose
        sql_condition = conditions.join(' AND ')
        [sql_condition, *params]
      end

      def validate_credentials!(args)
        unless class_variable_get(:@@credentials).size == args.size
          raise BadCredentials.new("Wrong number of arguments.
            Get #{args.size} of #{class_variable_get(:@@credentials).size}")
        end

        raise BadCredentials.new("Params should not be blank!") if args.any?(&:blank?)
      end
    end

    def create_authentication
      Authentication.new(self)
    end

    def hash_password
      self.password = self.class.generate_hash(password) if password_changed?
    end
  end
end
