require "rails_helper"

RSpec.describe Order, type: :model do
  describe "Validations" do
    it "is valid with valid attributes" do
      order = Order.new(product_name: "Test Product", quantity: 1, price: 100.00)
      expect(order).to be_valid
    end

    it "is invalid without a product name" do
      order = Order.new(product_name: nil, quantity: 1, price: 100.00)
      expect(order).not_to be_valid
      expect(order.errors[:product_name]).to include("can't be blank")
    end

    it "is invalid with a quantity less than 1" do
      order = Order.new(product_name: "Test Product", quantity: 0, price: 100.00)
      expect(order).not_to be_valid
      expect(order.errors[:quantity]).to include("must be greater than or equal to 1")
    end

    it "is invalid with a price less than or equal to 0" do
      order = Order.new(product_name: "Test Product", quantity: 1, price: 0)
      expect(order).not_to be_valid
      expect(order.errors[:price]).to include("must be greater than 0")
    end
  end

  describe "Status updates" do
    let(:order) { Order.create(product_name: "Test Product", quantity: 1, price: 100.00) }

    context "initial state" do
      it "is pending_payment" do
        expect(order.status).to eq("pending_payment")
      end
    end

    context "when transitioning from pending_payment" do
      it "transitions to authorized with authorize event" do
        expect(order.may_authorize?).to be_truthy
        order.authorize
        expect(order.status).to eq("authorized")
      end
    end

    context "when transitioning from authorized" do
      before { order.authorize }

      it "transitions to partially_paid with partially_pay event" do
        expect(order.may_partially_pay?).to be_truthy
        order.partially_pay
        expect(order.status).to eq("partially_paid")
      end
    end

    context "when transitioning from partially_paid" do
      before do
        order.authorize
        order.partially_pay
      end

      it "transitions to paid with pay event" do
        expect(order.may_pay?).to be_truthy
        order.pay
        expect(order.status).to eq("paid")
      end
    end

    context "when transitioning from paid" do
      before do
        order.authorize
        order.partially_pay
        order.pay
      end

      it "transitions to partially_refunded with partially_refund event" do
        expect(order.may_partially_refund?).to be_truthy
        order.partially_refund
        expect(order.status).to eq("partially_refunded")
      end
    end

    context "when transitioning from partially_refunded" do
      before do
        order.authorize
        order.partially_pay
        order.pay
        order.partially_refund
      end

      it "transitions to refunded with refund event" do
        expect(order.may_refund?).to be_truthy
        order.refund
        expect(order.status).to eq("refunded")
      end
    end

    context "invalid transitions" do
      it "does not allow transitioning from pending_payment to partially_paid directly" do
        expect(order.may_partially_pay?).to be_falsey
      end

      it "does not allow transitioning from paid back to authorized" do
        order.authorize
        order.partially_pay
        order.pay
        expect(order.may_authorize?).to be_falsey
      end
    end
  end
end
