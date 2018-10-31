require './input.rb'
require './output.rb'
require 'ecdsa'

class Transaction
  attr_accessor :id, :inputs, :outputs
  def initialize(id, inputs, outputs)
    @id = id
    @inputs = inputs
    @outputs = outputs
  end

  def set_id
    @id = rand(999999999999)
  end

  def is_coinbase?
    @inputs[0].output == -1
  end

  def sign(private_key, prev_transactions)
    return if is_coinbase?

    tx_copy = trimmed_copy
    tx_copy.inputs.each.with_index do |input, input_idx|
      prev_tx = prev_transactions[input.transaction_id]
      tx_copy.inputs[input_idx].signature = nil
      tx_copy.inputs[input_idx].pubkey = prev_tx.outputs[input.output].pubkey_hash
      tx_copy.id = tx_copy.get_hash
      tx_copy.inputs[input_idx].pubkey = nil

      group = ECDSA::Group::Secp256k1
      nonce = 1 + SecureRandom.random_number(group.order - 1)
      sig = ECDSA.sign(group, private_key, tx_copy.id, nonce)
      signature = ECDSA::Format::SignatureDerString.encode(sig)
      @inputs[input_idx].signature = signature
    end
  end

  def trimmed_copy
    inputs = []
    outputs = []
    @inputs.each do |input|
      inputs.push Input.new(input.transaction_id, input.output, nil)
    end
    @outputs.each do |output|
      outputs.push Output.new(output.value, output.pubkey_hash)
    end
    tx_copy = Transaction.new(@id, inputs, outputs)
  end

  def verify(prev_transactions)
    tx_copy = trimmed_copy
    curve = ECDSA::Group::Secp256k1

    @inputs.each.with_index do |input, input_idx|
      prev_tx = prev_transactions[input.transaction_id]
      tx_copy.inputs[input_idx].signature = nil
      tx_copy.inputs[input_idx].pubkey = prev_tx.outputs[input.output].pubkey_hash
      tx_copy.id = tx_copy.get_hash
      tx_copy.inputs[input_idx].pubkey = nil

      decode_sig = ECDSA::Format::SignatureDerString.decode(input.signature)
      pubkeys = ECDSA.recover_public_key(ECDSA::Group::Secp256k1, tx_copy.id, decode_sig).map do |pub|
        ECDSA::Format::PointOctetString.encode(pub, compression: true).unpack("H*")
      end
      pubkeys.each do |pub|
        pure_pubkey = pub[0][2..-1]
        address = pub_to_address(pure_pubkey)
        return true if address == input.pubkey
      end
      p "Invalid transaction"
      return false
    end
  end

  def pub_to_address(pubkey)
    pubkey = "02" + pubkey
    sha256_pubkey = Digest::SHA256.hexdigest [pubkey].pack("H*")
    rmd160_sha256_pubkey = Digest::RMD160.hexdigest [sha256_pubkey].pack("H*")
    versoined_rmd160_sha256_pubkey = "00" + rmd160_sha256_pubkey

    sha256_versoined_rmd160_sha256_pubkey = Digest::SHA256.hexdigest [versoined_rmd160_sha256_pubkey].pack("H*")
    sha256_sha256_versoined_rmd160_sha256_pubkey = Digest::SHA256.hexdigest [sha256_versoined_rmd160_sha256_pubkey].pack("H*")
    checksum = sha256_sha256_versoined_rmd160_sha256_pubkey[0..7]
    row_address = versoined_rmd160_sha256_pubkey + checksum
    address = Base58.binary_to_base58([row_address].pack("H*"), :bitcoin)
  end

  def get_hash
    components = ""
    self.inputs.each do |input|
      components += input.pubkey
    end
    hash = Digest::SHA256.hexdigest components
  end
end
