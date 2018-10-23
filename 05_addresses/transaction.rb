class Transaction
  attr_accessor :id, :inputs, :outputs
  def initialize(id, inputs, outputs)
    @id = id
    @inputs = inputs
    @outputs = outputs
  end

  def set_id
    @id = rand(999999999999)
  end

  def is_coinbase?
    @inputs[0].output == -1 && @inputs[0].script_sig == "This is Coinbase Transaction."
  end
end
