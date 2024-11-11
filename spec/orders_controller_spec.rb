require 'rails_helper'

RSpec.describe OrdersController, type: :request do
  let!(:order) do
    Order.create(
      product_name: "Dummy Order",
      quantity: 1,
      price: 99.99
    )
  end
  let!(:valid_jwt) { generate_jwt(user_id: 1) }
  let!(:random_jwt_token) { "random_token_that_fails" }

  describe 'Authorization' do
    it "forbids unauthorized request" do
      get "/orders/#{order.id}", headers: { 'Authorization' => "Bearer #{random_jwt_token}" }
    end
  end

  describe 'GET #show' do
    context 'when the order exists' do
      it 'returns the order' do
        get "/orders/#{order.id}", headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(order.id)
      end
    end

    context 'when the order does not exist' do
      it 'returns 404 not found error' do
        non_existant_id = 999
        get "/orders/#{non_existant_id}", headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Order not found')
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { order: { product_name: "test", quantity: 2, price: 99.99 } } }
    let(:invalid_params) { { order: { product_name: "test", quantity: 0, price: 0 } } }

    context 'when the request is valid' do
      it 'creates a new order and returns a success response' do
        post "/orders", params: valid_params, headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['product_name']).to eq('test')
        expect(JSON.parse(response.body)['quantity']).to eq(2)
        expect(JSON.parse(response.body)['price']).to eq("99.99")
      end
    end

    context 'when the request is invalid' do
      it 'returns an error response for invalid params' do
        post "/orders", params: invalid_params, headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Unable to create order')
        expect(JSON.parse(response.body)['messages']).to include("Quantity must be greater than or equal to 1", "Price must be greater than 0")
      end
    end
  end

  describe 'PUT #update' do
    let!(:order) do
      Order.create(
        product_name: "Dummy Order",
        quantity: 1,
        price: 99.99
      )
    end
    let(:valid_params) { { order: { product_name: "test", quantity: 2, price: 99.99, status: 'authorized' } } }
    let(:invalid_params) { { order: { product_name: "test", quantity: 0, price: 0 } } }
    let(:invalid_state_transition_params) { { order: { product_name: "test", quantity: 2, price: 99.99, status: 'paid'} } }

    context 'when the request is valid' do
      it 'updates the order status and returns a success response' do
        put "/orders/#{order.id}", params: valid_params, headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']).to eq('authorized')
      end
    end

    context 'when the state transition is invalid' do
      it 'returns an error response for an invalid state transition' do
        put "/orders/#{order.id}", params: invalid_state_transition_params, headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Invalid state transition')
      end
    end

    context 'when the order parameters are invalid' do
      it 'returns an error response for invalid parameters' do
        put "/orders/#{order.id}", params: invalid_params, headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Invalid order parameters')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the order exists' do
      it 'deletes the order and returns a no content response' do
        delete "/orders/#{order.id}", headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Order successfully deleted')
      end
    end

    context 'when the order does not exist' do
      it 'returns an error response for a non-existing order' do
        non_existant_id = 999
        delete "/orders/#{non_existant_id}", headers: { 'Authorization' => "Bearer #{valid_jwt}" }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Order not found')
      end
    end
  end
end