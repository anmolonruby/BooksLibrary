class BooksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :correct_user, only: [ :show, :destroy, :edit, :update ]

  def new
    @book = Book.new
    @book.authors.build
    if params[:place_id].present?
      session[:return_to] = place_path(params[:place_id])
      @book.place_id = params[:place_id]
    end
  end

  def create
    @book = Book.new(params[:book])
    @book.user_id = current_user.id
    if @book.save
      if session[:return_to].present? && @book.place_id
        redirect_to place_path(@book.place_id)
      else
        redirect_to books_path
      end
      session.delete(:return_to)
    else
      render 'new'
    end
  end

  def index
    @books = current_user.books
  end

  def show
  end

  def destroy
    @book.destroy
    flash[:success] = 'Book deleted'
    redirect_to books_path
  end

  def edit
  end

  def update
    if @book.update_attributes(params[:book]) && update_sold_date(@book)
      flash[:success] = 'Book updated'
      if params[:commit].present?
        redirect_to @book
      else
        redirect_to :back
      end
    else
      render 'edit'
    end
  end

  def import
    temp = Book.import(params[:file], current_user)
    flash[temp[:key]] = temp[:value]
    redirect_to edit_user_registration_path(current_user)
  end

  private

  def correct_user
    @book = Book.find_by_id(params[:id])
    if @book
      owner = @book.user
      redirect_to books_path unless current_user == owner
    else
      redirect_to books_path
    end
  end

  def update_sold_date(book)
    if book.sold?
      book.sold_date = Time.now if book.sold_date.blank?
    else
      book.sold_date = nil
    end
    book.save
  end
end
