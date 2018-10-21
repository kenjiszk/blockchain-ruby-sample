require './block.rb'
require './proof_of_work.rb'
require './transaction.rb'
require './input.rb'
require './output.rb'
require 'redis'

class Blockchain
  def initialize
    @nonce_limit = 10000000
  end

  def create_genesis_block
    create_block([coinbase], "This is Genesis Block.", "")
  end

  def add_block(data)
    redis = Redis.new(host: "localhost", port: 6379, db: 03)
    last_hash = redis.get "last_hash"
    create_block(data, last_hash)
  end

  def create_block(transactions, prev_block_hash)
    block = Block.new(Time.now.to_i, transactions, prev_block_hash)
    pow = ProofOfWork.new(block)
    if pow.calcurate(@nonce_limit)
      redis = Redis.new(host: "localhost", port: 6379, db: 03)
      redis.set "last_hash", block.hash
      redis.set block.hash, block.serialize
    end
  end

  def validate
    @blocks.each.with_index {|block, i|
      if i != 0
        p block.prev_block_hash == @blocks[i - 1].hash
      end
      pow = ProofOfWork.new(block)
      p pow.validate
    }
  end

  def deserialize_block(data)
    Marshal.load(data)
  end

  def create_or_load
    redis = Redis.new(host: "localhost", port: 6379, db: 03)
    last_hash = redis.get "last_hash"
    if last_hash.nil?
      create_genesis_block
    else
      p last_hash
    end
  end

  def create_coinbase_tx(to, data)
    if data.empty?
      data = "Reward to #{to}"
    end
    txin = Input.new([], -1, data)
    txout = Output.new(10000, to)
    tx = Transaction.new(nil, [txin], [txout])
    tx.set_id
    p tx
  end
end
