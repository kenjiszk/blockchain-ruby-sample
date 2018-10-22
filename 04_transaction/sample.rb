require './blockchain.rb'

bc = Blockchain.new
bc.create_or_load
utxos = bc.utxos('ADDRESS')
balance = 0
utxos.each {|utxo|
  balance += utxo.value
}
p balance

tx = bc.new_utxo_transaction('ADDRESS', 'BBBB', 10)
bc.add_block([tx])
