# Rails form_with Form Helper

## Learning Objectives

By the end of this lesson, you will be able to:

- Create forms using Rails form helpers in ERB templates
- Use `form_with` to build forms with and without model objects
- Handle form data in controllers using strong parameters
- Display form validation errors in your views
- Pass data from controllers to views using instance variables

## Introduction

You've just learned about `form_tag` and `form_for` in previous lessons, but I now have some bad news for you. These trusty helpers have served Rails developers for years, but, like dial-up internet and flip phones, they’re now on the Rails 7+ endangered species list. As of Rails 5.1, both `form_for` and `form_tag` are officially deprecated and headed for a well-earned retirement in the great code graveyard in the sky.

But don’t worry—your time learning them was not wasted! You’ll still encounter both in legacy codebases throughout your career, and knowing how they work will help you read and update older projects.

Now that you're familiar with both, you can appreciate why Rails introduced `form_with`: a single, modern helper that combines the best of both approaches. Think of it as the Swiss Army knife of form helpers—one tool to rule them all!

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

## The `form_with` Helper: The Modern, Unified Approach

`form_with` is the Rails way to create forms in ERB templates. It replaces both `form_tag` (for non-model forms) and `form_for` (for model-backed forms), giving you a single, consistent API for all form scenarios.

### Why Use `form_with`?

- **Unified helper:** Handles both model-backed and custom forms
- **Cleaner code:** One syntax for all forms
- **Future-proof:** Older helpers are deprecated

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

**Important:** For now, always include `local: true` so forms submit normally (not via AJAX). You’ll learn more about AJAX and Turbo/Hotwire in later lessons.

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

#### Displaying Form Validation Errors

To help users fix mistakes, show validation errors in your form view:

```erb
<% if @book.errors.any? %>
  <div class="errors">
    <h2><%= pluralize(@book.errors.count, "error") %> prevented this book from saving:</h2>
    <ul>
      <% @book.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

## `form_with` vs `form_for` (and `form_tag`)

You might see older Rails code using `form_for` or `form_tag` instead of `form_with`. `form_for` and `form_tag` are still used in legacy codebases, but they are deprecated in Rails 7+. For new code, always use `form_with`. Understanding the differences is important for working with both legacy and modern Rails applications.

### `form_for` (Legacy)

`form_for` was the primary way to create model-backed forms in Rails before version 5.1. You'll still see it in older codebases, but for new code, use `form_with`.

```erb
<!-- Old form_for -->
<%= form_for @book do |f| %>
  <%= f.text_field :title %>
<% end %>

<!-- Modern form_with -->
<%= form_with model: @book, local: true do |f| %>
  <%= f.text_field :title %>
<% end %>
```

**`form_for` characteristics:**

- **Model-only**: Only works with model objects (ActiveRecord instances)
- **Automatic routing**: Automatically generates URLs based on the model's state (new vs persisted)
- **Traditional submission**: Submits forms normally (not AJAX) by default
- **Separate helpers needed**: Required `form_tag` for non-model forms
- **Limited flexibility**: Different syntax for nested resources and custom URLs

### `form_with` (Modern - Use This)

`form_with` was introduced in Rails 5.1 as a unified form helper. It replaces both `form_for` and `form_tag` (deprecated in Rails 7+). Always use `form_with` for new code.

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

- **Unified helper**: Replaces both `form_for` (model forms) and `form_tag` (custom forms), which are deprecated
- **Flexible routing**: Can handle any URL pattern or HTTP method
- **AJAX by default**: Submits via AJAX unless `local: true` is specified (for now, always use `local: true` so forms behave as you expect)
- **Consistent API**: Same syntax for all form types
- **Modern features**: Better integration with Rails UJS and Turbo (you’ll learn more about this in future lessons)

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

By default, `form_with` submits forms via AJAX (using Rails UJS/Turbo). For now, always use `local: true` so forms submit normally and reload the page, just like you’ve seen so far. You’ll learn more about AJAX and Turbo/Hotwire in later lessons.

#### 3. **Parameter Structure**

Both helpers generate the same parameter structure when using models:

```ruby
# Both generate: { "book" => { "title" => "...", "author" => "..." } }
```

For non-model forms, you can use the `scope:` option to control the params shape:

```erb
<%= form_with url: books_path, scope: :book, local: true do |f| %>
  <%= f.text_field :title %>
<% end %>
```

Submits as:

```ruby
{ "book" => { "title" => "..." } }
```

Without `scope: :book`, it would be:

```ruby
{ "title" => "..." }
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

1. **Future-proof**: `form_for` and `form_tag` are deprecated and will be removed in future Rails versions
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

## Common Form Input Types

Rails provides helpers for common input types. Here are the most frequently used:

```erb
<%= form_with model: @book, local: true do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title %>

  <%= form.label :description %>
  <%= form.text_area :description %>

  <%= form.label :genre %>
  <%= form.select :genre, ['Fiction', 'Non-Fiction', 'Mystery', 'Romance'] %>

  <%= form.submit %>
<% end %>
```

For a full list of input helpers (checkboxes, radio buttons, dates, etc.), see the [Rails Form Helpers Guide](https://guides.rubyonrails.org/form_helpers.html).

## Adding Labels

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

## Recap: Key Takeaways

- `form_with` is the modern, unified form helper in Rails
- Use `model:` for ActiveRecord-backed forms
- Use `url:` or `scope:` for custom/non-model forms
- Always use `local: true` (for now) so forms submit normally
- Use strong parameters in your controller for security
- Show validation errors in your views to help users fix mistakes

For more input types and advanced form features, check the [Rails Form Helpers Guide](https://guides.rubyonrails.org/form_helpers.html).

---

In the next lab, you'll practice using `form_with` to build forms for new and edit actions, using strong parameters and validation errors.

## Code Examples

This repository (<https://github.com/powercodeacademy/phrg-basic-rails-forms-readme>) includes code examples that demonstrate all the form concepts covered in this README. The example files show:

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
