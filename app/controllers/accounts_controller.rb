class AccountsController < ApplicationController

  def index
    accounts = Account.all
    render json: { accounts: accounts }, status: 200
  end

  def show
    account = Account.find(params[:id])
    return head :not_found unless account
    render json: account, status: 200
  end

  def create
    account = Account.create(account_params)

    if account.save
      render json: account, status: 201
    else
      render json: { errors: account.errors }, status: 422
    end
  end

  def update
    account = Account.find(params[:id])
    return head :not_found unless account
    if account.update_attributes(account_params)
      render json: account, status: 200
    else
      render json: { errors: account.errors }, status: 422
    end
  end

  def destroy
    account = Account.find(params[:id])
    return head :not_found unless account
    account.destroy
    head 204
  end

  def deposit
    account = Account.find(params[:id])
    return head :not_found unless account
    return head :unprocessable_entity unless Account.deposit(account, amount)
    render json: {deposited: true}
  end

  def withdraw
    account = Account.find(params[:id])
    return head :not_found unless account
    return head :unprocessable_entity unless Account.withdraw(account, amount)
    render json: {withdrawn: true}
  end

  def transfer
    account = Account.find(params[:id])
    return head :not_found unless account

    recipient_param = params.permit(:recipient_id)
    recipient = Account.find(recipient_param[:recipient_id])
    return head :not_found unless recipient

    return head :unprocessable_entity unless Account.transfer(account, recipient, amount)
    render json: {transfered: true}
  end

  def inject_capital
    account = Account.find(params[:id])
    return head :not_found unless account
    return head :unprocessable_entity unless Account.inject_capital(account, amount)
    render json: {inject_capital: true}
  end

  private
  def account_params
    params.require(:account).permit(:name, :balance, :kind, :status, :accountable_type, :accountable_id)
  end

  def amount
    param = params.permit(:amount)
    param[:amount].to_f
  end
end
