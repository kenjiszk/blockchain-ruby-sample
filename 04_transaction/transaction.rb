class Transaction
  def initialize(id, inputs, outputs)
    @id = id
    @inputs = inputs
    @outputs = outputs
  end

  def set_id
    @id = rand(16)
  end
end
