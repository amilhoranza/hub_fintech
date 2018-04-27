class Account < ApplicationRecord

  class TransactionError < StandardError; end

  enum status: [ :active, :bloqued, :canceled ]
  enum kind: [ :head_office, :subsidiary ]

  has_many :accounts, as: :accountable
  belongs_to :accountable, polymorphic: true, optional: true

  validates_presence_of :name, :kind

  def all_children
    all = []
    self.accounts.each do |account|
      all << account
      root_children = account.all_children.flatten
      all << root_children unless root_children.empty?
    end
    return all.flatten
  end

  def self.deposit(account, amount, transaction_status = :false, description = "Depositing #{amount} on account #{account.id}", create_transaction = true)
    return false unless self.amount_valid?(amount)

    ActiveRecord::Base.transaction do
      Transaction.create(from: account, to: account, kind: :deposit, amount: amount, reversed: transaction_status,  description: description) if create_transaction
      account.balance = (account.balance += amount).round(2)
      account.save!
    end
  end

  def self.withdraw(account, amount, transaction_status = :false, description = "Withdrawing #{amount} on account #{account.id}", create_transaction = true)
    return false unless self.amount_valid?(amount)
    ActiveRecord::Base.transaction do
      Transaction.create(from: account, to: account, kind: :withdraw, amount: amount, reversed: transaction_status,  description: description) if create_transaction
      account.balance = (account.balance -= amount).round(2)
      account.save!
    end
  end

  def self.transfer(account, recipient, amount, transaction_status = :false, description = "Transfering #{amount} from account #{account.id} to account #{recipient.id}")
    puts "Transfering #{amount} from account #{account.id} to account #{recipient.id}"

    return false unless self.accounts_are_active?(account, recipient)
    return false unless self.amount_valid?(amount)
    return false unless self.recipient_is_child?(account, recipient)
    unless self.recipient_is_subsidiary?(recipient)
      raise TransactionError, "Transaction failed! Only subsidiary can receive a transfer."
      return false
    end

    ActiveRecord::Base.transaction do
      Transaction.create(from: account, to: recipient, kind: :transfer, amount: amount, reversed: transaction_status, description: description)
      self.withdraw(account, amount, false, "Withdrawing from a tranfer operation of #{amount} on account #{account.id}", false)
      self.deposit(recipient, amount, false, "Depositing from a tranfer operation of #{amount} on account #{recipient.id}", false)
    end
  end

  def self.inject_capital(account, amount)

    unless self.is_head_office?(account)
      return false
      raise TransactionError, "Transaction failed! Only head_office can receive a capital_injection."
    end

    create_transaction = false
    reversed = false
    Account.transaction do
      Transaction.create(from: account, to: account, kind: "capital_injection", amount: amount, description: "Injecting capital of #{amount} to #{account.id}")
      self.deposit(account, amount, reversed, "Injecting capital of #{amount} to #{account.id}", create_transaction)
    end
  end

  private

  def self.amount_valid?(amount)
    if not amount.is_a?(Numeric)
      raise TransactionError, "Transaction failed! Amount must be a valid number."
      return false
    elsif amount <= 0
      return false
      raise TransactionError, "Transaction failed! Amount must be greater than 0.00."
    end
    return true
  end

  def self.recipient_is_child?(account, recipient)
     unless account.all_children.include? recipient
      return false
      raise TransactionError, "Transaction failed! Account must be a child account to receive a transfer."
     end
     return true
  end

  def self.accounts_are_active?(account, recipient)
     unless account.active? and recipient.active?
      raise TransactionError, "Transaction failed! Accounts must be active to give or receive a transfer."
      return false
     end
     return true
  end

  def self.recipient_is_subsidiary?(recipient)
     unless recipient.subsidiary?
      return false
     end
     return true
  end

  def self.is_head_office?(account)
     unless account.head_office?
      return false
     end
     return true
  end

end
