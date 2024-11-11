class Order < ApplicationRecord
  include AASM

  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 1 }
  validates :price, numericality: { greater_than: 0 }

  aasm :status do
    state :pending_payment, initial: true
    state :authorized
    state :partially_paid
    state :paid
    state :refunded
    state :partially_refunded

    event :authorize do
      transitions from: :pending_payment, to: :authorized
    end

    event :partially_pay do
      transitions from: :authorized, to: :partially_paid
    end

    event :pay do
      transitions from: :partially_paid, to: :paid
    end

    event :partially_refund do
      transitions from: :paid, to: :partially_refunded
    end

    event :refund do
      transitions from: :partially_refunded,to: :refunded
    end
  end
end
