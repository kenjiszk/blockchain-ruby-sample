require 'base58'
require 'digest'

class Wallet
  def initialize(private_key, public_key)
    @private_key = private_key
    @public_key = public_key
  end

  def address
    p public_key_hash
    #versioned_payload = "00" + public_key_hash
    #full_payload = versioned_payload + checksum(versioned_payload)
    #p Base58.int_to_base58(full_payload.to_i(16))
  end

  def public_key_hash
    p joined_public_key
    aaa = joined_public_key.hex.to_s
    #aaa = "0" + joined_public_key.hex.to_s(16)
    p 'aaa'
    p aaa
    pub_sha256 = Digest::SHA256.hexdigest aaa
    p pub_sha256
    pub_rmd160 = Digest::RMD160.hexdigest pub_sha256
    pub_rmd160 = Digest::RMD160.hexdigest "0b7c28c9b7290c98d7438e70b3d3f7c848fbd7d1dc194ff83f4f7cc9b1378e98"
    p pub_rmd160
    pub_rmd160
  end

  def joined_public_key
    '02' + @public_key.x.to_s(16).to_s + @public_key.y.to_s(16).to_s
  end

  def checksum(payload)
    double_sha = Digest::SHA256.hexdigest Digest::SHA256.hexdigest payload
    double_sha[-4..-1]
  end
end
