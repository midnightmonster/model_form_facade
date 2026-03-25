# Scenario D: Svelte DataForm with read-only fields and write guards.
class PagesController < ApplicationController
  def index
  end

  def new
  end

  def create
    page_form.set_fields(params)
    page_form.save!
    redirect_to pages_path, status: 303
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    page_form.set_fields(params)
    page_form.save!
    redirect_to pages_path, status: 303
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render :edit, status: :unprocessable_entity
  end

  def destroy
    page.destroy
    redirect_to pages_path, status: 303
  end

  private

  helper_method def pages = Page.order(:name)

  helper_method def page
    @page ||= if params[:id]
      Page.find(params[:id])
    else
      Page.new.tap { |p| p.build_rich_content }
    end
  end

  helper_method def page_form
    @page_form ||= PageForm.new(page)
  end
end
