# Rails Simple Orders Application

This application is a simple Rails API for managing orders, demonstrating JWT-based authentication, AASM for order state management, and RSpec tests. The database setup is managed via Docker Compose.

## Features
- **Order Management**: Create, read, update, and delete orders.
- **JWT Authentication**: Secures API endpoints with a hardcoded token.
- **AASM Integration**: Manages state transitions for orders.
- **RSpec Tests**: Full test coverage for controllers and models.

## Prerequisites
- **Docker** and **Docker Compose** for setting up and running the database.
- **Ruby on Rails** installed.

## Setup

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Install Gems**:
   ```bash
   bundle install
   ```

3. **Configure Database**:
   Use Docker Compose to manage the database.
   ```bash
   docker-compose up -d
   ```

4. **Setup Database**:
   ```bash
   rails db:create db:migrate
   ```

5. **Run Tests**:
   Execute RSpec tests to ensure everything is working.
   ```bash
   rspec
   ```

## Authentication

### JWT Authentication (Hardcoded)
This application uses **JWT (JSON Web Token)** for securing API endpoints. The implementation uses a **hardcoded** secret key to sign and verify the JWT tokens is fixed in the code. The token is required in the `Authorization` header for all API requests.

### Authorization Header Format
To authorize, add the token to your request headers:
```
Authorization: Bearer <your-hardcoded-token>
```

## AASM - Order State Management
This app uses AASM to handle various states for orders. Each order can transition between states like `pending`, `authorized`, `partially_paid`, `paid` and `refunded`.

## Running the App

1. **Start the Rails Server**:
   ```bash
   rails s
   ```

2. **Access the API**:
   - **Create an Order**: `POST /orders`
   - **View an Order**: `GET /orders/:id`
   - **Update an Order**: `PUT /orders/:id`
   - **Delete an Order**: `DELETE /orders/:id`

3. **Order State Transitions**:
To update an order's state, make a PUT request to the /orders/:id endpoint with the desired status parameter in the body. Ensure the request includes a valid JWT in the Authorization header.

cURL Example

```bash
curl -X PUT http://localhost:3000/orders/1 \
-H "Content-Type: application/json" \
-H "Authorization: Bearer <your-hardcoded-token>" \
-d '{
  "order": {
    "product_name": "test",
    "quantity": 2,
    "price": 99.99,
    "status": "pending_payment"
  }
}'
```

Expected Response
A successful response should include the updated order details and the new status:

```json
{
  "id": 1,
  "product_name": "test",
  "quantity": 2,
  "price": 99.99,
  "status": "authorized",
  "created_at": "2024-11-11T12:00:00Z",
  "updated_at": "2024-11-11T12:05:00Z"
}
```

Status Transitions: Only valid transitions are permitted. If an invalid status transition is attempted, the API will respond with an error.

## Testing

The application includes comprehensive RSpec tests for:
- **Controllers**: Tests all endpoints in `OrdersController` and JWT authorization.
- **Models**: Tests validations, AASM state transitions

Run tests using:
```bash
rspec
```