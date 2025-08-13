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

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])

    if @book.update(book_params)
      redirect_to @book, notice: 'Book updated successfully!'
    else
      render :edit
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :genre, :pages, :available, :format, :published_date)
  end
end
