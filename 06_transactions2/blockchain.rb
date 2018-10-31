require './block.rb'
require './proof_of_work.rb'
require './transaction.rb'
require './input.rb'
require './output.rb'
require './blockchain_scanner.rb'
require './wallet.rb'
require 'redis'
require 'ecdsa'
require 'securerandom'

class Blockchain
  def initialize
    @nonce_limit = 10000000
  end

  def create_genesis_block(coinbase_tx)
    create_block([coinbase_tx], "")
  end

  def add_block(transactions)
    redis = Redis.new(host: "localhost", port: 6379, db: 06)
    last_hash = redis.get "last_hash"
    create_block(transactions, last_hash)
  end

  def create_block(transactions, prev_block_hash)
    transactions.each do |transaction|
      break if prev_block_hash == ""
      if ! verify_transaction(transaction)
        return "Invalid Transaction!"
      end
    end

    block = Block.new(Time.now.to_i, transactions, prev_block_hash)
    pow = ProofOfWork.new(block)
    if pow.calcurate(@nonce_limit)
      redis = Redis.new(host: "localhost", port: 6379, db: 06)
      redis.set "last_hash", block.hash
      redis.set block.hash, block.serialize
    end
  end

  def validate
    @blocks.each.with_index {|block, i|
      if i != 0
        p block.prev_block_hash == @blocks[i - 1].hash
      end
      pow = ProofOfWork.new(block)
      p pow.validate
    }
  end

  def deserialize_block(data)
    Marshal.load(data)
  end

  def create_or_load(wallet)
    redis = Redis.new(host: "localhost", port: 6379, db: 06)
    last_hash = redis.get "last_hash"
    if last_hash.nil?
      coinbase_tx = create_coinbase_tx(wallet, 'This is Coinbase Transaction.')
      create_genesis_block(coinbase_tx)
    else
      p last_hash
    end
  end

  def create_coinbase_tx(to, data)
    if data.empty?
      data = "Reward to #{to}"
    end
    txin = Input.new([], -1, data)
    txout = Output.new(10000, to)
    tx = Transaction.new(nil, [txin], [txout])
    tx.set_id
    tx
  end

  def find_utxs(address)
    spent_txos = {}
    utxs = []
    blocks = BlockchainScanner.new.scan
    blocks.each do |block|
      block.transactions.each do |transaction|
        catch(:break_loop) do
          transaction.outputs.each.with_index do |output, output_idx|
            if spent_txos[transaction.id] != nil
              spent_txos[transaction.id].each do |spent_out|
                throw :break_loop if spent_out == output_idx
              end
            end
            if output.is_locked_with_key(address)
              utxs.push transaction
            end
          end
        end
        unless transaction.is_coinbase?
          transaction.inputs.each do |input|
            if input.uses_key(address)
              spent_txos[input.transaction_id] = [] if spent_txos[input.transaction_id].nil?
              spent_txos[input.transaction_id].push input.output
            end
          end
        end
      end
      break if block.prev_block_hash == ""
    end
    utxs
  end

  def utxos(address)
    utxos = []
    utxs = find_utxs(address)
    utxs.each do |utx|
      utx.outputs.each do |output|
        if output.is_locked_with_key(address)
          utxos.push output
        end
      end
    end
    utxos
  end

  def new_utxo_transaction(wallet, to, amount)
    from = wallet.address
    inputs = []
    outputs = []
    acc, valid_outputs = find_spendable_output(from, amount)
    return "this account doesn't have enough coin." if acc < amount

    valid_outputs.each do |transaction_idx, output_idxs|
      output_idxs.each do |output|
        inputs.push Input.new(transaction_idx, output, from)
      end
    end

    outputs.push Output.new(amount, to)
    if acc > amount
      outputs.push Output.new(acc - amount, from)
    end

    tx = Transaction.new(nil, inputs, outputs)
    tx.set_id
    sign_transaction(tx, wallet.private_key)
    tx
  end

  def find_spendable_output(address, amount)
    unspent_outputs = {}
    unspent_transactions = find_utxs(address)
    accumulated = 0
    catch(:break_loop) do
      unspent_transactions.each do |transaction|
        transaction.outputs.each.with_index do |output, output_index|
          if output.is_locked_with_key(address) && accumulated < amount
            accumulated += output.value
            unspent_outputs[transaction.id] = [] if unspent_outputs[transaction.id].nil?
            unspent_outputs[transaction.id].push output_index
            throw :break_loop if accumulated >= amount
          end
        end
      end
    end
    return accumulated, unspent_outputs
  end

  def new_wallet
    private, public = new_key_pair
    wallet = Wallet.new(private, public)
  end

  def new_key_pair
    group = ECDSA::Group::Secp256k1
    private_key = 1 + SecureRandom.random_number(group.order - 1)
    public_key = group.generator.multiply_by_scalar(private_key)
    return private_key, public_key
  end

  def find_transaction(id)
    blocks = BlockchainScanner.new.scan
    blocks.each do |block|
      block.transactions.each do |transaction|
        return transaction if id == transaction.id
      end
    end
    return []
  end

  def sign_transaction(transaction, private_key)
    prev_transactions = {}
    transaction.inputs.each do |input|
      prev_transaction = find_transaction(input.transaction_id)
      prev_transactions[prev_transaction.id] = prev_transaction
    end
    transaction.sign(private_key, prev_transactions)
  end

  def verify_transaction(transaction)
    prev_transactions = {}
    transaction.inputs.each do |input|
      prev_transaction = find_transaction(input.transaction_id)
      prev_transactions[prev_transaction.id] = prev_transaction
    end

    return transaction.verify(prev_transactions)
  end
end
