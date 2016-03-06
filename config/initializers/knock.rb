Knock.setup do |config|

  ## User handle attribute
  ## ---------------------
  ##
  ## The attribute used to uniquely identify a user.
  ##
  ## Default:
  config.handle_attr = :email

  ## Current user retrieval from handle when signing in
  ## --------------------------------------------------
  ##
  ## This is where you can configure how to retrieve the current user when
  ## signing in.
  ##
  ## Knock uses the `handle_attr` variable to retrieve the handle from the
  ## AuthTokenController parameters. It also uses the same variable to enforce
  ## permitted values in the controller.
  ##
  ## You must raise ActiveRecord::RecordNotFound if the resource cannot be retrieved.
  ##
  ## Default:
  config.current_user_from_handle = -> (handle) { User.find_by! Knock.handle_attr => handle }

  ## Current user retrieval when validating token
  ## --------------------------------------------
  ##
  ## This is how you can tell Knock how to retrieve the current_user.
  ## By default, it assumes you have a model called `User` and that
  ## the user_id is stored in the 'sub' claim.
  ##
  ## You must raise ActiveRecord::RecordNotFound if the resource cannot be retrieved.
  ##
  ## Default:
  config.current_user_from_token = -> (claims) { User.find claims['id'] }


  ## Expiration claim
  ## ----------------
  ##
  ## How long before a token is expired.
  ##
  ## Default:
  # config.token_lifetime = 1.day


  ## Audience claim
  ## --------------
  ##
  ## Configure the audience claim to identify the recipients that the token
  ## is intended for.
  ##
  ## Default:
  # config.token_audience = nil

  ## If using Auth0, uncomment the line below
  # config.token_audience = -> { Rails.application.secrets.auth0_client_id }

  ## Signature algorithm
  ## -------------------
  ##
  ## Configure the algorithm used to encode the token
  ##
  ## Default:
  config.token_signature_algorithm = 'HS256'

  ## Signature key
  ## -------------
  ##
  ## Configure the key used to sign tokens.
  ##
  ## Default:
  config.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }

  ## If using Auth0, uncomment the line below
  # config.token_secret_signature_key = -> { JWT.base64url_decode Rails.application.secrets.auth0_client_secret }
  
  ## extracted from original [method](http://www.rubydoc.info/github/jwt/ruby-jwt/JWT.base64url_decode)
  require 'base64'
  config.token_secret_signature_key = -> {
      secret = Rails.application.secrets.auth0_client_secret
      secret += '=' * (4 - secret.length.modulo(4))
      Base64.decode64(secret.tr('-_', '+/'))
    }

  ## Public key
  ## ----------
  ##
  ## Configure the public key used to decode tokens, if required.
  ##
  ## Default: nil
  config.token_public_key = '4eda0940f4b680eaa3573abedb9d34dc5f878d241335c4f9ef189fd0c874e078ad1a658f81853b69a6334b2109c3bc94852997c7380ccdebbe85d766947fde69'
end
