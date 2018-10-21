class Block
  def initialize
    @timestamp
    @data
    @prev_block_hash
    @hash
  end

  def set_hash
    timestamp = Time.new().to_i
  end
end
