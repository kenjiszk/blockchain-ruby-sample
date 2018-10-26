require './blockchain.rb'

bc = Blockchain.new
bc.create_or_load("1LxZYbiwHi1vfD1ugxMMTs2FHZ7X7mHvNn")

#wallet = bc.new_wallet
#p "ADDRESS : " + wallet.address

#utxos = bc.utxos("1LxZYbiwHi1vfD1ugxMMTs2FHZ7X7mHvNn")
#p utxos
#balance = 0
#utxos.each do |utxo|
#  p utxo
#  balance += utxo.value
#end
#p balance

tx = bc.new_utxo_transaction(
  "1LxZYbiwHi1vfD1ugxMMTs2FHZ7X7mHvNn",
  "1Q1pm9RwDELxFdPS3pw2CLzDs1r6hBEXNv",
  10
)

tx.sign
#bc.add_block([tx])


#utxos = bc.utxos("1LxZYbiwHi1vfD1ugxMMTs2FHZ7X7mHvNn")
#balance = 0
#utxos.each do |utxo|
#  balance += utxo.value
#end
#p balance

#utxos = bc.utxos("1Q1pm9RwDELxFdPS3pw2CLzDs1r6hBEXNv")
#balance = 0
#utxos.each do |utxo|
#  balance += utxo.value
#end
#p balance
