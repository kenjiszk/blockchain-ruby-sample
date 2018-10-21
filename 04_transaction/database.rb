require './blockchain.rb'

bc = Blockchain.new
bc.create_or_load
bc.add_block("1BTC")
