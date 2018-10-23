class Output
  attr_accessor :value, :script_pub_key

  def initialize(value, script_pub_key)
    @value = value
    @script_pub_key = script_pub_key
  end

  def can_be_unlocked_with(unlockingData)
    @script_pub_key == unlockingData
  end
end
