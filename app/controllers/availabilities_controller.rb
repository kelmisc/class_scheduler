class AvailabilitiesController < ApplicationController
  before_action :authenticate_user!, except: [ :results ]
  before_action :check_if_volunteer?, except: [:search, :results]
  before_action :check_if_student?, only: [:search ]

  def results
    search = Contexts::Availabilities::Search.new(permit_search_params)
    results = search.execute

    if results.present?
      teachers = results.collect { |teacher| UserDecorator.new(teacher) }
      teachers = teachers.collect { |teacher| teacher.simple_decorate }
      render json: { teachers: teachers }, status: :ok
    else
      head :no_content
    end
  end

  def search
    user = UserDecorator.new(current_user).simple_decorate
    courses = Course.all
    timezones = ActiveSupport::TimeZone.all.sort
    days =  Date::DAYNAMES

    @data = {
        :currentUser => user,
        :courses => courses,
        :timezones => timezones,
        :days => days
    }

    render :search
  end

  def new
    user = UserDecorator.new(current_user).simple_decorate
    courses = Course.all
    timezones = ActiveSupport::TimeZone.all.sort
    days =  Date::DAYNAMES

    @data = {
        :availabilities => { },
        :currentUser => user,
        :courses => courses,
        :timezones => timezones,
        :days => days
    }

    render :new
  end

  def create
    if permitted_params.present?
      message = []
      status = []
      permitted_params.each do |n|
        creation = Contexts::Availabilities::Creation.new(permitted_nested(n), current_user)

        begin
          @availability = creation.execute
        rescue Contexts::Availabilities::Errors::UnknownAvailabilityError,
            Contexts::Availabilities::Errors::OverlappingAvailability,
            Contexts::Availabilities::Errors::ShortAvailability => e
          message << e.message
          status << :unprocessable_entity
        else
          message << { availability: `#{@availability.id} successfully created` }
        end
      end
      render :json=> { :message => message }, :status => :ok
    end
  end

  def index
    user = UserDecorator.new(current_user).simple_decorate
    courses = current_user.courses
    availabilities = Availability.where(:user => current_user)

    @data = {
        :currentUser => user,
        :courses => courses,
        :availabilities => availabilities
    }

    respond_with(@data, :index)
  end

  def destroy
    @availability = Availability.find(params[:id])
    @availability.destroy

    redirect_to availabilities_path
  end

  private

  def check_if_volunteer?
    unless current_user.teacher?
      redirect_to root_path
    end
  end

  def check_if_student?
    unless current_user.student?
      redirect_to root_path
    end
  end

  def build_search
    { :start_time => '', :end_time => '', :day => '' }
  end

  def permitted_params
    params.require(:availabilities)
  end

  def permitted_nested(n)
    n.permit(
        :day,
        :start_time,
        :end_time,
        :timezone
    )
  end

  def permit_search_params
    params.permit(
        :day,
        :start_time,
        :end_time,
        :timezone,
        :course,
    )
  end
end
