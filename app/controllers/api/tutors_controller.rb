class Api::TutorsController < ApplicationController
	def create
		@tutor = Tutor.new(tutor_params)
		if @tutor.save
			render 'api/tutors/show'
		else
			render json: @tutor.errors, status: :unprocessable_entity
		end
	end

	def show
		@tutor = Tutor.find(params[:id])
	end

	def index
		@tutors = Tutor.all.includes(:schedules)

		unless tutor_search_params.empty?
			@tutors = @tutors.where(tutor_search_params)
		end

		unless klass_params.empty?
			@tutors = @tutors.where(klasses: klass_params)
		end

		unless schedule_params.empty?
			@tutors = @tutors.where(schedules: schedule_params)
		end
	end

	private

	def tutor_params
		params.require(:tutor).permit(
			:email, 
			:password, 
			:phone_number, 
			:f_name, 
			:l_name, 
			:profile_src, 
			:type, 
			:language
		)
	end

	def tutor_search_params
		params.fetch(:tutor, {}).permit(
			:email, 
			:phone_number, 
			:f_name, 
			:l_name, 
			:profile_src, 
			:type, 
			:language
		).to_h
	end

	def klass_params
		params.fetch(:class, {}).permit(
			:id,
			:category,
			:title,
			:description
		).to_h
	end

	def schedule_params
		params.fetch(:schedule, {}).permit(
		:sun_mor,
		:sun_aft,
		:sun_eve,
		:mon_mor,
		:mon_aft,
		:mon_eve,
		:tue_mor,
		:tue_aft,
		:tue_eve,
		:wed_mor,
		:wed_aft,
		:wed_eve,
		:thu_mor,
		:thu_aft,
		:thu_eve,
		:fri_mor,
		:fri_aft,
		:fri_eve,
		:sat_mor,
		:sat_aft,
		:sat_eve
		).to_h
	end
end
