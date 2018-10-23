require 'digest/sha2'

class Block
  attr_accessor :timestamp, :transactions, :prev_block_hash, :hash, :nonce
  def initialize(timestamp, transactions, prev_block_hash)
    @timestamp = timestamp
    @transactions = transactions
    @prev_block_hash = prev_block_hash
    @hash = nil
    @nonce = nil
  end

  def set_hash
    headers = @prev_block_hash.to_s + @data.to_s + @timestamp.to_s
    @hash = Digest::SHA256.hexdigest headers
  end

  def serialize
    Marshal.dump(self)
  end

  def transactions_hash
    transaction_ids = @transactions.map{|transaction| transaction.id}
    Digest::SHA256.hexdigest transaction_ids.join
  end
end
