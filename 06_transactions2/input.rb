class Input
  attr_accessor :transaction_id, :output, :signature, :pubkey

  def initialize(transaction_id, output, pubkey)
    @transaction_id = transaction_id
    @output = output
    @signature
    @pubkey = pubkey
  end

  def uses_key(pubkey_hash)
    pubkey_hash = hash_pubkey(@pubkey)
  end

  def hash_pubkey(pubkey)
    versioned_pubkey = "02" + pubkey
    sha256_pubkey = Digest::SHA256.hexdigest [versioned_pubkey].pack("H*")
    rmd160_sha256_pubkey = Digest::RMD160.hexdigest [sha256_pubkey].pack("H*")
    versoined_rmd160_sha256_pubkey = "00" + rmd160_sha256_pubkey
  end

  #def can_unlock_output_with(unlocking_data)
  #  @script_sig == unlocking_data
  #end
end
