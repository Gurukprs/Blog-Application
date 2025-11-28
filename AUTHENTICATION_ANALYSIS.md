# Devise Authentication Analysis

## Overview
This application uses the Devise gem for user authentication. Devise provides a complete authentication solution with sign up, sign in, sign out, password recovery, and "remember me" functionality.

## How Authentication Works

### 1. User Model and Database

The `User` model is generated with Devise and includes the following modules:
- `:database_authenticatable` - Handles password encryption and authentication
- `:registerable` - Allows users to sign up
- `:recoverable` - Password reset functionality
- `:rememberable` - "Remember me" functionality
- `:validatable` - Email and password validations

**Database Schema** (from `devise_create_users` migration):
- `email` (string, indexed, unique) - User's email address
- `encrypted_password` (string) - BCrypt hashed password
- `reset_password_token` (string, indexed, unique) - For password recovery
- `reset_password_sent_at` (datetime) - When password reset was sent
- `remember_created_at` (datetime) - When "remember me" was set
- `created_at` / `updated_at` - Timestamps

### 2. Authentication Flow

#### Sign Up Process:
1. User visits `/users/sign_up`
2. User fills in email and password
3. Devise validates:
   - Email format and uniqueness
   - Password length (minimum 6 characters by default)
   - Password confirmation match
4. Password is encrypted using BCrypt
5. User record is created in database
6. User is automatically signed in
7. User is redirected to root path

#### Sign In Process:
1. User visits `/users/sign_in`
2. User enters email and password
3. Devise:
   - Finds user by email
   - Compares provided password with `encrypted_password` using BCrypt
   - If match, creates a session
4. User is redirected to root path or previously requested page

#### "Remember Me" Functionality:
When a user checks "Remember me" during sign in:
1. Devise creates a `remember_token` (encrypted)
2. Stores it in a cookie (expires in 2 weeks by default)
3. On subsequent requests:
   - Devise checks for the remember token cookie
   - If valid, automatically signs in the user
   - User doesn't need to re-enter credentials

**How Remember Me Works:**
- Cookie is stored client-side with `HttpOnly` flag for security
- Token is stored in `remember_created_at` field in database
- Token is validated on each request if session is not present
- Token can be revoked by signing out

### 3. Session Management

#### How Users Stay Logged In:

**Session-Based Authentication:**
- When user signs in, Devise creates a session
- Session ID is stored in a cookie (session cookie)
- Cookie is sent with every request
- Rails retrieves user from session on each request
- Session expires when:
  - Browser is closed (if not "remember me")
  - User explicitly signs out
  - Session timeout (configurable)

**Remember Token (Persistent Login):**
- Separate from session cookie
- Stored in a separate cookie with longer expiration
- Used when session cookie is not present
- Allows user to stay logged in across browser sessions

### 4. Application Controller Configuration

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
end
```

**What `authenticate_user!` does:**
1. Checks if `current_user` is set (from session or remember token)
2. If not authenticated:
   - Stores the requested URL
   - Redirects to `/users/sign_in`
   - After sign in, redirects back to originally requested URL
3. If authenticated, allows the request to proceed

**Helper Methods Available:**
- `current_user` - Returns the currently signed-in user
- `user_signed_in?` - Boolean check if user is authenticated
- `authenticate_user!` - Forces authentication (redirects if not signed in)

### 5. Password Security

**BCrypt Hashing:**
- Passwords are NEVER stored in plain text
- BCrypt creates a one-way hash with salt
- Each password gets a unique salt (even same password has different hash)
- Comparison is done using `BCrypt::Password.new(encrypted_password) == provided_password`
- Original password cannot be recovered from hash

**Example:**
```ruby
# User enters: "password123"
# Stored in DB: "$2a$12$KIXxKIXxKIXxKIXxKIXxKIXxKIXxKIXxKIXxKIXxKIXxKIXxKIXx"
# Each login: BCrypt compares provided password with stored hash
```

### 6. Request Flow with Authentication

**Authenticated Request:**
1. Browser sends request with session/remember cookie
2. `ApplicationController#authenticate_user!` runs
3. Devise extracts user from session/remember token
4. Sets `current_user` for the request
5. Controller action executes
6. Response sent back

**Unauthenticated Request:**
1. Browser sends request without valid session
2. `ApplicationController#authenticate_user!` runs
3. No valid session/remember token found
4. Requested URL stored in session
5. Redirect to `/users/sign_in`
6. User signs in
7. Redirect to originally requested URL

### 7. Routes

Devise automatically creates these routes:
- `GET /users/sign_up` - Sign up form
- `POST /users` - Create new user
- `GET /users/sign_in` - Sign in form
- `POST /users/sign_in` - Authenticate user
- `DELETE /users/sign_out` - Sign out
- `GET /users/password/new` - Forgot password form
- `POST /users/password` - Send password reset email
- `GET /users/password/edit` - Reset password form
- `PATCH /users/password` - Update password

### 8. Security Features

**CSRF Protection:**
- All forms include CSRF tokens
- Rails validates tokens on POST/PUT/DELETE requests

**Password Requirements:**
- Minimum length: 6 characters (configurable)
- Email validation: Must be valid email format
- Email uniqueness: No duplicate emails

**Session Security:**
- Session cookies are HttpOnly (not accessible via JavaScript)
- Secure cookies in production (HTTPS only)
- Session fixation protection

**Password Reset Security:**
- Reset tokens expire after 6 hours (configurable)
- Tokens are single-use
- Tokens are cryptographically secure

### 9. Testing Authentication

**In RSpec Tests:**
```ruby
# Sign in a user
let(:user) { create(:user) }
before { sign_in user }

# Sign out
sign_out user

# Check authentication
expect(controller.current_user).to eq(user)
expect(controller.user_signed_in?).to be true
```

**Factory Bot:**
```ruby
factory :user do
  email { "user@example.com" }
  password { "password123" }
  password_confirmation { "password123" }
end
```

### 10. Configuration Files

**`config/initializers/devise.rb`:**
- Main Devise configuration
- Password length, email regex, session timeout
- Remember me duration (default: 2 weeks)
- Lockable settings, etc.

**`config/routes.rb`:**
- `devise_for :users` - Generates all authentication routes

**Environment Files:**
- `config.action_mailer.default_url_options` - Required for password reset emails

### 11. Key Concepts

**Session vs Remember Token:**
- **Session**: Temporary, expires when browser closes (unless remember me)
- **Remember Token**: Persistent, survives browser restarts, stored in separate cookie

**Authentication vs Authorization:**
- **Authentication** (Devise): "Who are you?" - Verifies user identity
- **Authorization** (CanCanCan/Pundit): "What can you do?" - Controls access to resources

**Current User:**
- Available in controllers and views
- Set automatically by Devise on each request
- `nil` if not authenticated

## Summary

Devise provides a complete authentication system that:
1. Securely stores passwords using BCrypt
2. Manages user sessions and remember tokens
3. Provides sign up, sign in, sign out functionality
4. Handles password recovery
5. Protects against common security vulnerabilities
6. Integrates seamlessly with Rails controllers and views

Users are authenticated on every request through session cookies or remember tokens, allowing them to stay logged in without re-entering credentials for each interaction with the application.

