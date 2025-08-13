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

## `form_with` vs `form_for`

You might see older Rails code using `form_for` instead of `form_with`. Understanding the differences is important for working with both legacy and modern Rails applications.

### `form_for` (Legacy - Avoid in New Code)

`form_for` was the primary way to create model-backed forms in Rails before version 5.1:

```erb
<!-- Basic form_for usage -->
<%= form_for @book do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title %>
  <%= form.label :author %>
  <%= form.text_field :author %>
  <%= form.submit %>
<% end %>

<!-- For editing existing records -->
<%= form_for [@publisher, @book] do |form| %>
  <%= form.text_field :title %>
  <%= form.submit %>
<% end %>
```

**`form_for` characteristics:**

- **Model-only**: Only works with model objects (ActiveRecord instances)
- **Automatic routing**: Automatically generates URLs based on the model's state (new vs persisted)
- **Traditional submission**: Submits forms normally (not AJAX) by default
- **Separate helpers needed**: Required `form_tag` for non-model forms
- **Limited flexibility**: Different syntax for nested resources and custom URLs

### `form_with` (Modern - Use This)

`form_with` was introduced in Rails 5.1 as a unified form helper:

```erb
<!-- Model-based form -->
<%= form_with model: @book, local: true do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title %>
  <%= form.label :author %>
  <%= form.text_field :author %>
  <%= form.submit %>
<% end %>

<!-- URL-based form (no model needed) -->
<%= form_with url: books_path, method: :post, local: true do |form| %>
  <%= form.text_field :title %>
  <%= form.submit %>
<% end %>

<!-- Scope-based form for custom parameter structure -->
<%= form_with scope: :book, url: books_path, local: true do |form| %>
  <%= form.text_field :title %>
  <%= form.submit %>
<% end %>
```

**`form_with` characteristics:**

- **Unified helper**: Works with models, URLs, or custom scopes
- **Flexible routing**: Can handle any URL pattern or HTTP method
- **AJAX by default**: Submits via AJAX unless `local: true` is specified
- **Consistent API**: Same syntax for all form types
- **Modern features**: Better integration with Rails UJS and Turbo

### Key Differences Explained

#### 1. **Flexibility**

```erb
<!-- form_for: Limited to models only -->
<%= form_for @book do |f| %>
  <!-- Works only with @book model -->
<% end %>

<!-- form_with: Works with models, URLs, or scopes -->
<%= form_with model: @book, local: true do |f| %>
  <!-- Model-based -->
<% end %>

<%= form_with url: "/custom-endpoint", local: true do |f| %>
  <!-- URL-based for any endpoint -->
<% end %>
```

#### 2. **AJAX Behavior**

```erb
<!-- form_for: Normal form submission by default -->
<%= form_for @book do |f| %>
  <!-- Submits normally, reloads page -->
<% end %>

<!-- form_with: AJAX by default, normal with local: true -->
<%= form_with model: @book do |f| %>
  <!-- Submits via AJAX -->
<% end %>

<%= form_with model: @book, local: true do |f| %>
  <!-- Normal submission, reloads page -->
<% end %>
```

#### 3. **Parameter Structure**

Both helpers generate the same parameter structure when using models:

```ruby
# Both generate: { "book" => { "title" => "...", "author" => "..." } }
```

#### 4. **Nested Resources**

```erb
<!-- form_for: Array syntax for nested resources -->
<%= form_for [@publisher, @book] do |f| %>
  <!-- Creates URL like /publishers/1/books -->
<% end %>

<!-- form_with: More explicit model syntax -->
<%= form_with model: [@publisher, @book], local: true do |f| %>
  <!-- Same result, clearer intent -->
<% end %>
```

### Why `form_with` is Preferred

1. **Future-proof**: `form_for` is deprecated and will be removed in future Rails versions
2. **One helper to learn**: Instead of memorizing `form_for`, `form_tag`, and their differences
3. **More powerful**: Handles any form scenario with consistent syntax
4. **Better defaults**: Includes CSRF protection and works well with modern JavaScript frameworks
5. **Cleaner code**: Explicit parameters make intentions clear (`model:`, `url:`, `scope:`)
6. **Turbo integration**: Works seamlessly with Rails 7's Turbo framework

### Migration Strategy

When updating legacy code:

```erb
<!-- Old form_for -->
<%= form_for @book do |f| %>
  <%= f.text_field :title %>
<% end %>

<!-- New form_with equivalent -->
<%= form_with model: @book, local: true do |f| %>
  <%= f.text_field :title %>
<% end %>
```

The main change is adding `model:` and `local: true` parameters. Everything else stays the same!

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

## Key Points to Remember

1. **Always use `local: true`** in your `form_with` helper
2. **Use strong parameters** in your controller to prevent security issues
3. **Handle both success and failure cases** in your controller actions
4. **Include labels** for accessibility
5. **Use `form_with` instead of `form_for`** for modern Rails development

## Code Examples

This repository (https://github.com/powercodeacademy/phrg-basic-rails-forms-readme) includes code examples that demonstrate all the form concepts covered in this README. The example files show:

- **Models:** `Book` with basic setup
- **Controllers:** `BooksController` with form handling and strong parameters
- **Views:** Complete form examples including:
  - Model-based forms (`_book_form.html.erb`)
  - All input types from the README
- **Routes:** RESTful routes configuration

### Key Files to Study

1. `app/controllers/books_controller.rb` - Controller focused on form handling
2. `app/models/book.rb` - Basic model setup
3. `app/views/books/_book_form.html.erb` - Comprehensive form with all input types
4. `app/views/books/new.html.erb` and `edit.html.erb` - Form usage examples
5. `config/routes.rb` - RESTful routes for forms
