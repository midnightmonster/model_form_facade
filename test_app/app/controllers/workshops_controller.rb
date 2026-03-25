# Scenario B: Svelte DataForm with one/nested inline blocks.
class WorkshopsController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
    workshop_form.set_fields(params)
    workshop_form.save!
    redirect_to workshops_path, status: 303
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  def update
    workshop_form.set_fields(params)
    workshop_form.save!
    redirect_to workshops_path, status: 303
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    render :edit, status: :unprocessable_entity
  end

  def destroy
    workshop.destroy
    redirect_to workshops_path, status: 303
  end

  private

  helper_method def workshops = Workshop.order(start_date: :desc)

  helper_method def workshop
    @workshop ||= if params[:id]
      Workshop.find(params[:id])
    else
      Workshop.new.tap do |w|
        w.build_description
        w.build_pricing_info
      end
    end
  end

  helper_method def workshop_form
    @workshop_form ||= WorkshopForm.new(workshop)
  end
end
