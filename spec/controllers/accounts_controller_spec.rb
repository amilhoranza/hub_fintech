require 'rails_helper'

describe AccountsController do
  let!(:account) { create(:account) }


  describe 'POST create' do
    context 'with valid params' do
      let(:params) { { account: attributes_for(:account) } }

      it 'returns created status' do
        post :create, params: params, as: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'POST deposit' do
    context 'with valid params' do
      let(:params) { { id: account.id, amount: 9.99 } }

      it 'returns 200' do
        put :deposit, params: params, as: :json
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST withdraw' do
    context 'with valid params' do
      let(:params) { { id: account.id, amount: 9.99 } }

      it 'returns 200' do
        post :withdraw, params: params, as: :json
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST transfer' do
    context 'with valid params' do
      let!(:recipient) { create(:account, kind: "subsidiary", accountable_type: "Account", accountable_id: account.id) }
      let(:params) { { id: account.id, recipient_id: recipient.id, amount: 5.00 } }

      it 'returns 200' do
        post :transfer, params: params, as: :json
        expect(response).to have_http_status(:success)
      end
    end
  end
end
