require './blockchain.rb'

addr0= "1CK4ngUe4ECAYsKvfDijHETHAGNgBakjQj"
addr1 = "1LxZYbiwHi1vfD1ugxMMTs2FHZ7X7mHvNn"
addr2 = "1Q1pm9RwDELxFdPS3pw2CLzDs1r6hBEXNv"

bc = Blockchain.new

#wallet = Wallet.restore("17NGPUtEhZLGnmv8wVsuQyYdyyBKkxhj8r")
#wallet = bc.new_wallet
#p "ADDRESS : " + wallet.address
#wallet.save

bc.create_or_load("1CK4ngUe4ECAYsKvfDijHETHAGNgBakjQj")

def balance(bc, addr)
  utxos = bc.utxos(addr)
  balance = 0
  utxos.each do |utxo|
    balance += utxo.value
  end
  p balance
end

#wallet = bc.new_wallet
wallet = Wallet.restore(addr0)
p "ADDRESS : " + wallet.address
p wallet.public_key

tx = bc.new_utxo_transaction(wallet, addr1, 1)
bc.add_block([tx])

[addr0, addr1, addr2].each do |addr|
  balance(bc, addr)
end
