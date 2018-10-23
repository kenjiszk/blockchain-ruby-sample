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
    redis = Redis.new(host: "localhost", port: 6379, db: 05)
    last_hash = redis.get "last_hash"
    create_block(transactions, last_hash)
  end

  def create_block(transactions, prev_block_hash)
    block = Block.new(Time.now.to_i, transactions, prev_block_hash)
    pow = ProofOfWork.new(block)
    if pow.calcurate(@nonce_limit)
      redis = Redis.new(host: "localhost", port: 6379, db: 05)
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

  def create_or_load
    redis = Redis.new(host: "localhost", port: 6379, db: 05)
    last_hash = redis.get "last_hash"
    if last_hash.nil?
      coinbase_tx = create_coinbase_tx('ADDRESS', 'This is Coinbase Transaction.')
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
    spent_txos = []
    utxs = []
    blocks = BlockchainScanner.new.scan
    catch(:break_loop) do
      blocks.each {|block|
        block.transactions.each{|transaction|
          transaction.outputs.each.with_index{|output, output_idx|
            if spent_txos[transaction.id] != nil
              spent_txos[transaction.id].each{|spent_out|
                throw :break_loop if spent_out == output_index
              }
            end
            if output.can_be_unlocked_with(address)
              utxs.push transaction
            end
          }
          unless transaction.is_coinbase?
            transaction.inputs.each{|input|
              if input.can_unlock_output_with(address)
                spent_txos[input.transaction_id].push input.output
              end
            }
          end
        }
        break if block.prev_block_hash == ""
      }
    end
    utxs
  end

  def utxos(address)
    utxos = []
    utxs = find_utxs(address)
    utxs.each do |utx|
      utx.outputs.each do |output|
        if output.can_be_unlocked_with(address)
          utxos.push output
        end
      end
    end
    utxos
  end

  def new_utxo_transaction(from, to, amount)
    inputs = []
    outputs = []
    acc, valid_outputs = find_spendable_output(from, amount)
    return if acc < amount

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
    tx
  end

  def find_spendable_output(address, amount)
    unspent_outputs = {}
    unspent_transactions = find_utxs(address)
    accumulated = 0
    catch(:break_loop) do
      unspent_transactions.each do |transaction|
        p transaction
        transaction.outputs.each.with_index do |output, output_index|
          if output.can_be_unlocked_with(address) && accumulated < amount
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
    #private_key = 1 + SecureRandom.random_number(group.order - 1)
    private_key = "18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725".hex
    public_key = group.generator.multiply_by_scalar(private_key)
    return private_key, public_key
  end
end
