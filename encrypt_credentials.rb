#!/usr/bin/env ruby
require 'active_support/encrypted_configuration'
require 'active_support/key_generator'

# Read the master key
master_key = File.read('config/master.key').strip

# Read the credentials content
credentials_content = File.read('/tmp/new_credentials.yml')

# Create an encryptor
key_generator = ActiveSupport::KeyGenerator.new(master_key, iterations: 2**16)
secret = key_generator.generate_key('ActiveSupport::EncryptedFile', 32)

# Encrypt the content
encryptor = ActiveSupport::MessageEncryptor.new(secret, cipher: 'aes-128-gcm')
encrypted_content = encryptor.encrypt_and_sign(credentials_content)

# Write the encrypted credentials
File.write('config/credentials.yml.enc', encrypted_content)

puts "✅ Credentials encrypted successfully!"
