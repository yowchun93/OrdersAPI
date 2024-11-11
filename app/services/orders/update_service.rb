class Orders::UpdateService
  def initialize(order, order_params)
    @order = order
    @status = order_params.dig(:status)
    @order_params = order_params
  end

  def call
    @order.assign_attributes(@order_params.except(:status))
    return failure_response('Invalid order parameters') if @order.invalid?

    event = map_status_to_event

    if event && @order.send("may_#{event}?")
      @order.send("#{event}!")
      @order.save!
      success_response
    else
      failure_response('Invalid state transition')
    end
  end

  private

  def map_status_to_event
    event_mapping = {
      authorized: :authorize,
      paid: :pay,
      partially_paid: :partially_pay,
      refunded: :refund,
      partially_refunded: :partially_refund
    }

    event_mapping[@status.to_sym]
  end

  def success_response
    { success: true, order: @order }
  end

  def failure_response(message)
    { success: false, error: message }
  end
end