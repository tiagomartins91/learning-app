class CommentsController < ApplicationController

  before_action :set_course_lesson, only: [:create, :destroy]

  def create
    @comment = Comment.new(comment_params)
    @comment.lesson_id = @lesson.id
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to course_lesson_path(@course, @lesson), notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render 'lessons/comments/new' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])

    if @comment.destroy
      respond_to do |format|
        format.html { redirect_to course_lesson_path(@course, @lesson), notice: 'Comment was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_course_lesson
    @lesson = Lesson.friendly.find(params[:lesson_id])
    @course = Course.friendly.find(params[:course_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

end