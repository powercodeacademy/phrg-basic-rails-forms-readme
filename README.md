# Rails Forms with ERB

## Learning Objectives

By the end of this lesson, you will be able to:

- Create forms using Rails form helpers in ERB templates
- Use `form_with` to build forms with and without model objects
- Handle form data in controllers using strong parameters
- Display form validation errors in your views
- Pass data from controllers to views using instance variables

## Introduction

Forms are essential for web applications as they allow users to input data. Rails provides form helpers that generate HTML forms with built-in security features and easy integration with your Rails models.

## From HTML to Rails Forms

You already know basic HTML forms look like this:

```html
<form action="/books" method="post">
  <label for="title">Book Title:</label>
  <input type="text" id="title" name="title" />
  <input type="submit" value="Add Book" />
</form>
```

Rails form helpers make this easier and more secure. Instead of writing HTML directly, you use ERB with Rails helpers.

## The `form_with` Helper

`form_with` is the Rails way to create forms in ERB templates. It can work with or without model objects.

### Basic Form (Without a Model)

```erb
<%= form_with url: "/books", method: :post, local: true do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title %>

  <%= form.label :author %>
  <%= form.text_field :author %>

  <%= form.submit "Add Book" %>
<% end %>
```

**Important:** Always include `local: true` - this makes the form submit normally instead of using AJAX.

### Form With a Model (The Rails Way)

When you have a model object, Rails can automatically figure out the URL and HTTP method:

```erb
<%= form_with model: @book, local: true do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title %>

  <%= form.label :author %>
  <%= form.text_field :author %>

  <%= form.submit %>
<% end %>
```

Rails automatically:

- Uses POST for new records, PATCH for existing records
- Generates the correct URL based on your routes
- Creates appropriate submit button text

## Form Input Types

Rails provides helpers for common input types:

```erb
<%= form_with model: @book, local: true do |form| %>
  <!-- Text inputs -->
  <%= form.text_field :title %>
  <%= form.text_area :description %>
  <%= form.email_field :author_email %>
  <%= form.number_field :pages %>

  <!-- Dropdowns -->
  <%= form.select :genre, ['Fiction', 'Non-Fiction', 'Mystery', 'Romance'] %>

  <!-- Checkboxes and Radio Buttons -->
  <%= form.check_box :available %>
  <%= form.radio_button :format, 'hardcover' %>
  <%= form.radio_button :format, 'paperback' %>

  <!-- Dates -->
  <%= form.date_field :published_date %>

  <%= form.submit %>
<% end %>
```

### Adding Labels

Always include labels for accessibility and user experience:

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
<% end %>
```

## Connecting Forms to Controllers

### Setting Up the Controller

Your controller needs to handle displaying the form and processing the submitted data:

```ruby
class BooksController < ApplicationController
  def new
    @book = Book.new  # Empty book for the form
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      redirect_to @book, notice: 'Book created successfully!'
    else
      render :new  # Show the form again with errors
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :genre, :pages)
  end
end
```

### Strong Parameters

The `book_params` method uses "strong parameters" to specify which form fields are allowed. This prevents security vulnerabilities:

```ruby
def book_params
  # Only allow these specific fields from the form
  params.require(:book).permit(:title, :author, :genre, :pages, :available)
end
```

### Passing Data to Views

Use instance variables (like `@book`) to pass data from controllers to your ERB views:

```ruby
def new
  @book = Book.new           # For the form
  @publishers = Publisher.all # For dropdown options
end
```

## Routes for Forms

Your forms need routes to work. Here's the basic setup:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :books  # Creates all RESTful routes including new and create
end
```

This gives you:

- `GET /books/new` → `books#new` (shows the form)
- `POST /books` → `books#create` (processes the form)
- `GET /books/:id/edit` → `books#edit` (shows edit form)
- `PATCH /books/:id` → `books#update` (processes edit form)

## Displaying Validation Errors

When your model has validation errors, you can display them in your form:

```erb
<%= form_with model: @book, local: true do |form| %>
  <% if @book.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@book.errors.count, "error") %> prevented this book from being saved:</h2>
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

  <%= form.submit %>
<% end %>
```

The errors come from your model validations:

```ruby
class Book < ApplicationRecord
  validates :title, presence: true, length: { minimum: 2 }
  validates :author, presence: true
end
```

## Using Form Partials

To keep your code DRY (Don't Repeat Yourself), you can create reusable form partials:

```erb
<!-- _book_form.html.erb -->
<%= form_with model: book, local: true do |form| %>
  <% if book.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(book.errors.count, "error") %> prevented this book from being saved:</h2>
      <ul>
        <% book.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

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
```

Then use the partial in both your new and edit views:

```erb
<!-- new.html.erb -->
<h1>New Book</h1>
<%= render 'book_form', book: @book %>

<!-- edit.html.erb -->
<h1>Edit Book</h1>
<%= render 'book_form', book: @book %>
```

## Key Points to Remember

1. **Always use `local: true`** in your `form_with` helper
2. **Use strong parameters** in your controller to prevent security issues
3. **Handle both success and failure cases** in your controller actions
4. **Include labels** for accessibility
5. **Display validation errors** to help users fix their input

## Code Examples

This repository (https://github.com/powercodeacademy/phrg-basic-rails-forms-readme) includes code examples that demonstrate all the form concepts covered in this README. The example files show:

- **Models:** `Book`, `Chapter`, `Publisher` with validations and associations
- **Controllers:** `BooksController` with form handling and strong parameters
- **Views:** Complete form examples including:
  - Model-based forms (`_book_form.html.erb`)
  - Form validation and error handling
  - Nested forms for chapters
  - All input types from the README
- **Routes:** RESTful routes configuration

### Key Files to Study

1. `app/controllers/books_controller.rb` - Controller focused on form handling
2. `app/models/book.rb` - Model with validations and associations
3. `app/views/books/_book_form.html.erb` - Comprehensive form with all input types
4. `app/views/books/new.html.erb` and `edit.html.erb` - Form usage examples
5. `config/routes.rb` - RESTful routes for forms

## Practice Exercise

Now that you understand Rails forms, try creating your own form! Pick a simple model like:

- A `Recipe` with title, ingredients, and instructions
- A `Song` with title, artist, and genre
- A `Movie` with title, director, and year

Practice creating:

1. The model with validations
2. Controller actions for `new` and `create`
3. Routes
4. The form view with error handling

This will help reinforce what you've learned about Rails forms and ERB templates!
