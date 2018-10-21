require './block.rb'

class Blockchain
  attr_accessor :blocks

  def initialize
    @blocks = []
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
    block.set_hash
    @blocks.push(block)
  end
end
