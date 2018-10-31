require './blockchain.rb'

bc = Blockchain.new

#(1..3).each do |i|
#  wallet = bc.new_wallet
#  p "ADDRESS : " + wallet.address
#  wallet.save
#end
#return

addr0 ="1FNB2cvFTYUEftq8YpfGP7Mpmgs74ZLegr"
addr1 ="16ZjaGinJuZivxCfwp8UkHHuawLMbGWrvD"
addr2 ="1EVRNjUUYkGVsuDMrm6NNT1FdhQyXEBmzA"

bc.create_or_load(addr0)

def balance(bc, addr)
  utxos = bc.utxos(addr)
  balance = 0
  utxos.each do |utxo|
    balance += utxo.value
  end
  p balance
end

[addr0, addr1, addr2].each do |addr|
  p bc.find_utxs(addr)
  balance(bc, addr)
end

return

wallet0 = Wallet.restore(addr0)
wallet1 = Wallet.restore(addr1)
wallet2 = Wallet.restore(addr2)
#tx1 = bc.new_utxo_transaction(wallet0, addr2, 1)
#tx2 = bc.new_utxo_transaction(wallet1, addr2, 1)
tx2 = bc.new_utxo_transaction(wallet2, addr1, 1)
bc.add_block([tx2])

[addr0, addr1, addr2].each do |addr|
  balance(bc, addr)
end
