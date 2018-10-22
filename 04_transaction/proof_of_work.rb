class ProofOfWork
  def initialize(block)
    @target_bits = 20
    @target_block = block
    @target = set_target
  end

  def set_target
    (1 << (256 - @target_bits)).to_s(16)
  end

  def calcurate(nonce_limit)
    (1..nonce_limit).each{|nonce|
      headers = @target_block.prev_block_hash.to_s + @target_block.transactions_hash + @target_block.timestamp.to_s + nonce.to_s
      hash = Digest::SHA256.hexdigest headers   
      if (hash.hex < @target.hex)
        p nonce
        p hash
        @target_block.nonce = nonce
        @target_block.hash = hash
        return true
      end
    }
    false
  end

  def validate
    headers = @target_block.prev_block_hash.to_s + @target_block.transactions_hash.to_s + @target_block.timestamp.to_s + @target_block.nonce.to_s
    hash = Digest::SHA256.hexdigest headers
    hash.hex < @target.hex
  end
end
