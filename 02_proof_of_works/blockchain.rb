require './block.rb'
require './proof_of_work.rb'

class Blockchain
  attr_accessor :blocks

  def initialize
    @blocks = []
    @nonce_limit = 10000000
  end

  def create_genesis_block
    create_block("This is Genesis Block.", "")
  end

  def add_block(data)
    prev_block = @blocks.last
    create_block(data, prev_block.hash)
  end

  def create_block(data, prev_block_hash)
    block = Block.new(Time.now.to_i, data, prev_block_hash)
    pow = ProofOfWork.new(block)
    if pow.calcurate(@nonce_limit)
      @blocks.push(block)
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
end
