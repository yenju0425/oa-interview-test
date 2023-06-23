class TeachersController < ApplicationController
  def index
    teachers = Teacher.all
    render json: teachers
  end

  def create
    teacher = Teacher.new(teacher_params)
    if teacher.save
      render json: teacher, status: :created
    else
      render json: { errors: teacher.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    teacher = Teacher.find(params[:id])
    if teacher.destroy
      render json: { message: "Teacher successfully deleted." }, status: :ok
    else
      render json: { errors: teacher.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def follow
    # check teacher
    teacher = Teacher.find_by(id: params[:teacher_id]) # RICKNOTE find_by v.s. find
    unless teacher
      render json: { errors: "Teacher not found" }, status: :unprocessable_entity
      return
    end

    # follow students
    follow_failed_ids = teacher.follow_students(params[:student_ids])
    if follow_failed_ids.empty?
      render json: teacher, status: :created
    else
      render json: { errors: "One or more students failed to follow", follow_failed_ids: follow_failed_ids }, status: :unprocessable_entity
    end

  rescue ActiveRecord::InvalidForeignKey => e
    render json: { errors: e.message }, status: :unprocessable_entity
  end

  def unfollow
    #  check teacher
    teacher = Teacher.find_by(id: params[:teacher_id]) # RICKNOTE find_by v.s. find
    unless teacher
      render json: { errors: "Teacher not found" }, status: :unprocessable_entity
      return
    end

    # unfollow students
    unfollow_failed_ids = teacher.unfollow_students(params[:student_ids])
    if unfollow_failed_ids.empty?
      render json: teacher, status: :created
    else
      render json: { errors: "One or more students failed to unfollow", unfollow_failed_ids: unfollow_failed_ids }, status: :unprocessable_entity
    end

  rescue ActiveRecord::InvalidForeignKey => e
    render json: { errors: e.message }, status: :unprocessable_entity
  end

  private

  def teacher_params
    params.require(:teacher).permit(:name, :follow, :unfollow)
  end
end
