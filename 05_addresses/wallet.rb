require 'base58'
require 'digest'

class Wallet
  def initialize(private_key, public_key)
    @private_key = private_key
    @public_key = public_key
  end

  def address
    pubkey = "02" + @public_key.x.to_s(16)
    sha256_pubkey = Digest::SHA256.hexdigest [pubkey].pack("H*")
    rmd160_sha256_pubkey = Digest::RMD160.hexdigest [sha256_pubkey].pack("H*")
    versoined_rmd160_sha256_pubkey = "00" + rmd160_sha256_pubkey

    sha256_versoined_rmd160_sha256_pubkey = Digest::SHA256.hexdigest [versoined_rmd160_sha256_pubkey].pack("H*")
    sha256_sha256_versoined_rmd160_sha256_pubkey = Digest::SHA256.hexdigest [sha256_versoined_rmd160_sha256_pubkey].pack("H*")
    checksum = sha256_sha256_versoined_rmd160_sha256_pubkey[0..7]
    row_address = versoined_rmd160_sha256_pubkey + checksum
    address = Base58.binary_to_base58([row_address].pack("H*"), :bitcoin)
  end
end
