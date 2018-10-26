require 'base58'

class Output
  attr_accessor :value, :pubkey_hash

  def initialize(value, pubkey_hash)
    @value = value
    @pubkey_hash = pubkey_hash
  end

  def lock(address)
    pubkey_hash = Base58.binary_to_base58([address].pack("H*"), :bitcoin)
    @pubkey_hash = pubkey_hash
  end

  def is_locked_with_key(pubkey_hash)
    @pubkey_hash == pubkey_hash
  end

  #def can_be_unlocked_with(unlockingData)
  #  @script_pub_key == unlockingData
  #end
end
