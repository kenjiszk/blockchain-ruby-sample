require './input.rb'
require './output.rb'

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
    @inputs[0].output == -1
  end

  def sign(private_key, prev_transactions)
    return if is_coinbase?

    tx_copy = trimmed_copy
    tx_copy.each do |tx|
      prev_transaction = prev_transactions[]
    end
  end

  def trimmed_copy
    inputs = []
    outputs = []
    @inputs.each do |input|
      inputs.push Input.new(input.transaction_id, input.output, nil)
    end
    @outputs.each do |output|
      outputs.push Output.new(output.value, output.pubkey_hash)
    end
    tx_copy = Transaction.new(@id, inputs, outputs)
  end
end
