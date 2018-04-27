require 'rails_helper'

RSpec.describe Account, type: :model do

  let!(:account) { create(:account) }

  describe '#deposit' do
    context 'with valid params' do
      it 'deposit into account' do
        deposited = described_class.deposit(account, 9.99)
        expect(deposited).to eq true
      end
    end

    context 'when amount <= 0' do
      it 'returns falsy' do
        deposited = described_class.deposit(account, 0.00)
        expect(deposited).to eq false
      end
    end
  end

  describe '#withdraw' do
    context 'with valid params' do
      it 'withdraw from account' do
        withdrawn = described_class.withdraw(account, 9.99)
        expect(withdrawn).to eq true
      end
    end

    context 'when amount <= 0' do
      it 'returns falsy' do
        withdrawn = described_class.withdraw(account, 0.00)
        expect(withdrawn).to eq false
      end
    end
  end

  describe '#transfer' do
    let(:params_recipient) { attributes_for(:account) }
    let!(:recipient) { create(:account, params_recipient.merge(kind: "subsidiary", accountable_type: "Account", accountable_id: account.id)) }

    context 'with valid params' do
      it 'transfer from one account to another account' do
        transfered = described_class.transfer(account, recipient, 9.99)
        expect(transfered).to eq true
      end
    end

    context 'when amount <= 0' do
      it 'returns false' do
        transfered = described_class.transfer(account, recipient, 0.00)
        expect(transfered).to eq false
      end
    end
  end
end
