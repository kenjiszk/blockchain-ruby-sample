require './blockchain.rb'

addr0 = "1Lwd6HuFyJ962GkPjJ6gEjw7GcYKpZPfxT"
addr1 = "176adNAm3UYa22NrDcRv7XF7AJ8oiDWpWt"
addr2 = "19vmzSM6LETdmMq33NYkRhyUbFFpuUYPTL"

bc = Blockchain.new

#wallet = Wallet.restore("17NGPUtEhZLGnmv8wVsuQyYdyyBKkxhj8r")
#wallet = bc.new_wallet
#p "ADDRESS : " + wallet.address
#wallet.save

bc.create_or_load(addr0)

def balance(bc, addr)
  utxos = bc.utxos(addr)
  balance = 0
  utxos.each do |utxo|
    balance += utxo.value
  end
  p balance
end

# wallet = bc.new_wallet
wallet = Wallet.restore(addr0)
p "ADDRESS : " + wallet.address
# p wallet.public_key
# wallet.save

tx = bc.new_utxo_transaction(wallet, addr1, 1)
bc.add_block([tx])

[addr0, addr1, addr2].each do |addr|
  balance(bc, addr)
end
