class Transaction < ApplicationRecord

  class TransactionRevertedError < StandardError; end

  include UuidHelper

  enum kind: [ :deposit, :withdraw, :transfer, :capital_injection ]
  enum reversed: [ :false, :true ]

  belongs_to :to, :class_name => 'Account', :foreign_key => :to
  belongs_to :from, :class_name => 'Account', :foreign_key => :from



  def self.reverse(uuid)
    Transaction.transaction do
      transaction = self.where(uuid: uuid, reversed: :false).take
      if transaction.present?
        if transaction.capital_injection?
          Account.withdraw(transaction.to, transaction.amount, :true, "reversing capital_injection on account number: #{transaction.to.id}")
        elsif transaction.withdraw?
          Account.deposit(transaction.to, transaction.amount, :true, "reversing withdraw on account number: #{transaction.to.id}")
        elsif transaction.transfer?
          Account.withdraw(transaction.to, transaction.amount, :true, "reversing transfer from account number: #{transaction.to.id} on account number: #{transaction.from.id}")
          Account.deposit(transaction.from, transaction.amount, :true, "reversing transfer from account number: #{transaction.to.id} on account number: #{transaction.from.id}")
        else
          Account.withdraw(transaction.to, transaction.amount, :true, "reversing deposit on account number: #{transaction.to.id}")
        end
        transaction.reversed = :true
        transaction.save!
      else
        raise TransactionRevertedError, "Transaction not found or already reverted."
      end
    end
  end

end
