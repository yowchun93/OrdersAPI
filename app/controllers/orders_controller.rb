class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update, :destroy]

  def show
    render json: @order
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      render json: @order, status: :created
    else
      render json: { error: 'Unable to create order', messages: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    service_response = Orders::UpdateService.new(@order, order_params).call

    if service_response[:success]
      render json: service_response[:order], status: :ok
    else
      render json: { error: service_response[:error] }, status: :unprocessable_entity
    end
  end

  def destroy
    if @order.destroy
      render json: { message: 'Order successfully deleted' }, status: :ok
    else
      render json: { error: 'Unable to delete order' }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find_by(id: params[:id])

    unless @order
      render json: { error: 'Order not found' }, status: :not_found
    end
  end

  def order_params
    params.require(:order).permit(:product_name, :quantity, :price, :status)
  end
end
