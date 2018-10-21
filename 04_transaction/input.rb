class Input
  def initialize(transaction_id, output, script_sig)
    @transaction_id = transaction_id
    @output = output
    @script_sig = script_sig
  end
end
