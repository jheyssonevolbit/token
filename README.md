## TokenAuth

This project rocks and uses MIT-LICENSE.

## Initializer Configuration


      TokenAuth.setup do |config|
        # Uncomment to redefine default expiration value
        # default - two hours
        # config.expire = 30.minutes

        config.auth_token_expire = 5.days
        config.exchange_token_expire = 15.days

        # This will reset auth token expiration on each request if true
        config.renew_authentication_token_on_each_request = false

        # Uncomment to redefine default salt value
        config.salt = '7c47d7710d9b62a31c149c49c6053d8087e0e13884ede241989db5beb178256d8274a090ae9a6581d137e0398eba1b8178127d469e069e204c0d88c0585e286d'

        # Uncomment to redefine default recovery pin expiration time
        # config.recovery_pin_expire = 30.minutes

        #  Uncomment to redefine default from email address
        # config.from_email = 'no-reply@domain.com'
      end



## Exceptions

This gem raises exceptions in negative cases. Look at the gem's code to figure out which exceptions should be handled.
