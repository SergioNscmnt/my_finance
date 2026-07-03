require "digest"

credentials = Rails.application.credentials.fetch(:active_record_encryption, {})

def encryption_key_from_env_or_credentials(name, credentials)
  ENV[name.to_s.upcase] || credentials[name]
end

def development_encryption_key(name)
  Digest::SHA256.hexdigest("my-finance-#{Rails.env}-#{name}")
end

primary_key = encryption_key_from_env_or_credentials(:active_record_encryption_primary_key, credentials)
deterministic_key = encryption_key_from_env_or_credentials(:active_record_encryption_deterministic_key, credentials)
key_derivation_salt = encryption_key_from_env_or_credentials(:active_record_encryption_key_derivation_salt, credentials)

unless Rails.env.production?
  primary_key ||= development_encryption_key(:primary_key)
  deterministic_key ||= development_encryption_key(:deterministic_key)
  key_derivation_salt ||= development_encryption_key(:key_derivation_salt)
end

if ENV["SECRET_KEY_BASE_DUMMY"].present?
  primary_key ||= development_encryption_key(:dummy_primary_key)
  deterministic_key ||= development_encryption_key(:dummy_deterministic_key)
  key_derivation_salt ||= development_encryption_key(:dummy_key_derivation_salt)
end

if [primary_key, deterministic_key, key_derivation_salt].any?(&:blank?)
  raise "Active Record Encryption keys are missing. Set ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY, ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY and ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT."
end

Rails.application.config.active_record.encryption.primary_key = primary_key
Rails.application.config.active_record.encryption.deterministic_key = deterministic_key
Rails.application.config.active_record.encryption.key_derivation_salt = key_derivation_salt

# Existing local databases may still contain plaintext values until the migration
# rewrites them. Keeping this enabled also makes fixture data tolerant.
Rails.application.config.active_record.encryption.support_unencrypted_data = true
