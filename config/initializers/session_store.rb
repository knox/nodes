# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_nodes_session',
  :secret      => '5bafaf299cb5af421bee0d65885dfc123830c8b09859c0387afc1fd9e5d856b22945d2feb3b63e2e16ae6cb547c889d6d735555f6b95251d4c519ae96ca08e0d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
