class Input
  attr_accessor :transaction_id, :output, :script_sig

  def initialize(transaction_id, output, script_sig)
    @transaction_id = transaction_id
    @output = output
    @script_sig = script_sig
  end

  def can_unlock_output_with(unlocking_data)
    @script_sig == unlocking_data
  end
end
