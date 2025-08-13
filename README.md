# Rails Forms: A Comprehensive Guide

## Learning Objectives

By the end of this lesson, you will be able to:

- Understand the basics of HTML forms and how they work with Rails
- Use Rails form helpers to create forms
- Understand the difference between `form_with`, `form_for`, and `form_tag`
- Handle form data in controllers using strong parameters
- Pass data from controllers to views using instance variables
- Create forms that work with and without model objects
- Understand form security and CSRF protection
- Handle form validation and error display

## Introduction

Forms are essential for web applications as they allow users to input data that can be processed by your Rails application. Rails provides powerful form helpers that make creating HTML forms easier and more secure.

## HTML Forms Basics

Before diving into Rails-specific helpers, let's understand basic HTML forms:

```html
<form action="/books" method="post">
  <label for="title">Book Title:</label>
  <input type="text" id="title" name="title" />

  <label for="author">Author:</label>
  <input type="text" id="author" name="author" />

  <input type="submit" value="Add Book" />
</form>
```

When this form is submitted:

1. The browser sends a POST request to `/books`
2. The form data is sent in the request body
3. Rails receives the data in the `params` hash

## Rails Form Helpers

Rails provides form helpers that generate HTML forms with additional features like CSRF protection, proper encoding, and integration with Rails conventions.

### The `form_with` Helper

`form_with` is the modern Rails way to create forms. It's flexible and can work with or without model objects.

#### Basic Form Without a Model

```erb
<%= form_with url: "/books", method: :post, local: true do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title %>

  <%= form.label :author %>
  <%= form.text_field :author %>

  <%= form.submit "Add Book" %>
<% end %>
```

**Key Parameters:**

- `url`: Where the form submits to
- `method`: HTTP method (`:post`, `:patch`, `:delete`, etc.)
- `local: true`: Makes the form submit normally (not via AJAX)
  - "Normally" means the browser does a full page reload/redirect after submission, like traditional HTML forms
  - Without `local: true`, Rails uses AJAX to submit the form in the background without changing the current page

#### Form With a Model

```erb
<%= form_with model: @book, local: true do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title %>

  <%= form.label :author %>
  <%= form.text_field :author %>

  <%= form.submit %>
<% end %>
```

When using `model: @book`:

- Rails automatically determines the URL and method
- For new records: POST to the collection route
- For existing records: PATCH to the member route
- The submit button text is automatically generated

### Form Input Types

Rails provides helpers for various input types:

```erb
<%= form_with model: @book, local: true do |form| %>
  <!-- Text inputs -->
  <%= form.text_field :title %>
  <%= form.text_area :description %>
  <%= form.password_field :password %>
  <%= form.email_field :author_email %>
  <%= form.number_field :pages %>

  <!-- Selection inputs -->
  <%= form.select :genre, ['Fiction', 'Non-Fiction', 'Mystery', 'Romance'] %>
  <%= form.collection_select :publisher_id, @publishers, :id, :name %>

  <!-- Boolean inputs -->
  <%= form.check_box :available %>
  <%= form.radio_button :format, 'hardcover' %>
  <%= form.radio_button :format, 'paperback' %>

  <!-- Date/Time inputs -->
  <%= form.date_field :published_date %>
  <%= form.datetime_local_field :added_to_library %>

  <!-- File uploads -->
  <%= form.file_field :cover_image %>

  <!-- Hidden fields -->
  <%= form.hidden_field :librarian_id %>
<% end %>
```

### Labels and Accessibility

Always include labels for form accessibility:

```erb
<%= form_with model: @book, local: true do |form| %>
  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>

  <div class="field">
    <%= form.label :author, "Author Name" %>
    <%= form.text_field :author %>
  </div>

  <div class="field">
    <%= form.label :isbn, "ISBN Number" %>
    <%= form.text_field :isbn %>
  </div>
<% end %>
```

## Controller Integration

### Handling Form Data

Controllers receive form data through the `params` hash:

```ruby
class BooksController < ApplicationController
  def new
    @book = Book.new  # For model-based forms
    # OR
    @book = {}        # For simple hash-based forms
  end

  def create
    @book = book_params

    # Process the data (save to database, send email, etc.)
    if @book.save
      redirect_to @book, notice: 'Book was successfully added.'
    else
      render :new
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :isbn, :genre, :pages)
  end
end
```

### Strong Parameters

Strong parameters prevent mass assignment vulnerabilities:

```ruby
# Require the :book key and permit specific attributes
def book_params
  params.require(:book).permit(:title, :author, :isbn, :genre, :pages)
end

# For nested attributes
def book_params
  params.require(:book).permit(:title, :author, chapters_attributes: [:title, :page_number])
end

# For arrays
def book_params
  params.require(:book).permit(:title, :author, tag_names: [])
end
```

### Passing Data to Views

Use instance variables to pass data from controllers to views:

```ruby
class BooksController < ApplicationController
  def new
    @book = Book.new
    @publishers = Publisher.all  # For select options
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book
    else
      @publishers = Publisher.all  # Reload data for the form
      render :new
    end
  end

  def show
    @book = Book.find(params[:id])
  end
end
```

## Working with Routes

Forms need corresponding routes:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # RESTful routes (recommended)
  resources :books

  # Or custom routes
  get '/newbook', to: 'books#new'
  post '/book', to: 'books#create'
  get '/books/:id', to: 'books#show'
end
```

RESTful routes provide:

- `GET /books/new` → `books#new`
- `POST /books` → `books#create`
- `GET /books/:id` → `books#show`
- `GET /books/:id/edit` → `books#edit`
- `PATCH/PUT /books/:id` → `books#update`

## CSRF Protection

Rails automatically includes CSRF (Cross-Site Request Forgery) protection:

```erb
<!-- Rails automatically adds this to forms -->
<input type="hidden" name="authenticity_token" value="...">
```

Ensure your `ApplicationController` includes:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
```

## Form Validation and Error Handling

### Model Validations

```ruby
class Book < ApplicationRecord
  validates :title, presence: true, length: { minimum: 2 }
  validates :author, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :pages, presence: true, numericality: { greater_than: 0 }
end
```

### Displaying Errors in Views

```erb
<%= form_with model: @book, local: true do |form| %>
  <% if @book.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@book.errors.count, "error") %> prohibited this book from being saved:</h2>
      <ul>
        <% @book.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title %>
    <% if @book.errors[:title].any? %>
      <span class="error"><%= @book.errors[:title].first %></span>
    <% end %>
  </div>
<% end %>
```

## Advanced Form Techniques

### Dynamic Forms with JavaScript

```erb
<%= form_with model: @book, local: true do |form| %>
  <div id="chapters">
    <%= form.fields_for :chapters do |chapter_form| %>
      <div class="chapter">
        <%= chapter_form.text_field :title %>
        <%= chapter_form.number_field :page_number %>
      </div>
    <% end %>
  </div>

  <button type="button" id="add-chapter">Add Chapter</button>
<% end %>
```

### Form Partials

Create reusable form partials:

```erb
<!-- _book_form.html.erb -->
<%= form_with model: book, local: true do |form| %>
  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>

  <div class="field">
    <%= form.label :author %>
    <%= form.text_field :author %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>

<!-- new.html.erb -->
<h1>New Book</h1>
<%= render 'book_form', book: @book %>

<!-- edit.html.erb -->
<h1>Edit Book</h1>
<%= render 'book_form', book: @book %>
```

### Nested Forms

For handling associated models:

```ruby
class Book < ApplicationRecord
  has_many :chapters
  accepts_nested_attributes_for :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

```erb
<%= form_with model: @book, local: true do |form| %>
  <%= form.text_field :title %>

  <%= form.fields_for :chapters do |chapter_form| %>
    <%= chapter_form.text_field :title %>
    <%= chapter_form.number_field :page_number %>
  <% end %>
<% end %>
```

## Best Practices

### 1. Always Use Strong Parameters

```ruby
# Good
def book_params
  params.require(:book).permit(:title, :author)
end

# Bad - security vulnerability
def create
  @book = Book.new(params[:book])
end
```

### 2. Handle Both Success and Failure Cases

```ruby
def create
  @book = Book.new(book_params)

  if @book.save
    redirect_to @book, notice: 'Book was successfully added.'
  else
    render :new  # Shows form with errors
  end
end
```

### 3. Use Semantic HTML and Proper Labels

```erb
<div class="form-group">
  <%= form.label :title, "Book Title" %>
  <%= form.text_field :title, required: true, placeholder: "Enter book title" %>
</div>
```

### 4. Provide User Feedback

```erb
<% flash.each do |type, message| %>
  <div class="alert alert-<%= type %>">
    <%= message %>
  </div>
<% end %>
```

## Form Security Considerations

1. **CSRF Protection**: Always enabled by default
2. **Strong Parameters**: Prevent mass assignment
3. **Input Validation**: Both client-side and server-side
4. **XSS Prevention**: Rails automatically escapes output
5. **File Upload Security**: Validate file types and sizes

```ruby
# Example of secure file upload handling
def book_params
  params.require(:book).permit(:title, :author, :cover_image).tap do |whitelisted|
    if whitelisted[:cover_image].present?
      # Validate file type and size
      unless whitelisted[:cover_image].content_type.in?(['image/jpeg', 'image/png'])
        # Handle invalid file type
      end
    end
  end
end
```

## Common Patterns and Use Cases

### 1. Search Forms

```erb
<%= form_with url: books_path, method: :get, local: true do |form| %>
  <%= form.text_field :search, placeholder: "Search books..." %>
  <%= form.submit "Search" %>
<% end %>
```

### 2. Filter Forms

```erb
<%= form_with url: books_path, method: :get, local: true do |form| %>
  <%= form.select :genre, options_for_select([['All', ''], ['Fiction', 'fiction'], ['Non-Fiction', 'non-fiction']]) %>
  <%= form.check_box :available_only %>
  <%= form.submit "Filter" %>
<% end %>
```

### 3. Multi-step Forms

```ruby
# Store form data in session across steps
session[:book_data] = params[:book]
```

## Debugging Forms

### Common Issues and Solutions

1. **Form not submitting**: Check routes and method
2. **Parameters not received**: Verify strong parameters
3. **CSRF token errors**: Ensure `protect_from_forgery` is set correctly
4. **Form fields not populating**: Check instance variable names

### Debugging Tools

```ruby
# In controller
puts params.inspect
puts book_params.inspect

# In view
<%= debug(@book) %>
<%= debug(params) %>
```

## Summary

Rails forms provide a powerful and secure way to handle user input. Key takeaways:

- Use `form_with` for modern Rails applications
- Always implement strong parameters for security
- Handle both success and failure cases in controllers
- Use proper labels and semantic HTML for accessibility
- Implement proper validation and error handling
- Follow RESTful conventions when possible

With these concepts, you'll be able to create robust forms that handle user input securely and effectively in your Rails applications.

## Practice Exercise

Now that you understand Rails forms through the book example, try applying these concepts to build a basketball team management form. Think about:

- What fields would a basketball team need?
- How would you structure the controller actions?
- What validations might be appropriate?
- How would you handle the form submission and display the results?

This will help you apply the form concepts you've learned to a different domain and reinforce your understanding!
