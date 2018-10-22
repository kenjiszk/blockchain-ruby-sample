require './block.rb'

class BlockchainScanner
  def scan
    blocks = []
    redis = Redis.new(host: "localhost", port: 6379, db: 04)
    last_hash = redis.get 'last_hash'
    while !last_hash.empty?
      data = redis.get last_hash
      block = deserialize_block(data)
      blocks.push block
      last_hash = block.prev_block_hash
    end
    blocks
  end

  def deserialize_block(data)
    Marshal.load(data)
  end
end
