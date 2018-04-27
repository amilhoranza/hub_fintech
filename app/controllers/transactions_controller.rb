class TransactionsController < ApplicationController

  def index
    transactions = Transaction.all
    render json: { transactions: transactions }, status: 200
  end

  def show
    transaction = Transaction.find(params[:id])
    return head :not_found unless transaction
    render json: transaction, status: 200
  end

  def reverse
    transaction = Transaction.where(uuid: params[:id], reversed: :false).take
    return head :not_found unless transaction
    return head :unprocessable_entity unless Transaction.reverse(params[:id])
    render json: {reversed: true}
  end


end
