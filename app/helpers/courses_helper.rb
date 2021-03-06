module CoursesHelper

  def enrollment_button(course)

    #link to check price
    unless current_user
      return link_to "Check price", new_course_enrollment_path(course), class: "btn btn-md btn-success"
    end

    if course.user == current_user
      return link_to "You created this course. View analytics!", course_path(course)
    end

    if is_user_enroll_this_course(course, current_user)
      return link_to course_path(course) do
        #"You bought this course. Keep learning!" + " " +
        "<i class='fa fa-spinner'></i>".html_safe + " " + number_to_percentage(course.progress(current_user), precision: 0)
      end

    end

    link_to  course.price > 0 ? number_to_currency(course.price): "Free", new_course_enrollment_path(course), class: "btn btn-md btn-success"
  end

  def review_button(course)
    return unless current_user

    if is_enrollment_not_reviewed(course, current_user)
      return link_to edit_enrollment_path(user_course_enrollments(course, current_user)) do
        "<i class='text-warning fa fa-star'></i>".html_safe + " " + 'Add a review'
      end
    end

    unless course.user == current_user || !is_user_enroll_this_course(course, current_user)
      link_to enrollment_path(user_course_enrollments(course, current_user)) do
        "<i class='fa fa-check'></i>".html_safe + " " + 'Thanks for reviewing! Your review.'
      end
    end

  end

  private

  def is_user_enroll_this_course(course, current_user)
    course.enrollments.where(user: current_user).any?
  end

  def is_enrollment_not_reviewed(course, current_user)
    course.enrollments.where(user: current_user).pending_review.any?
  end

  def user_course_enrollments(course, current_user)
    course.enrollments.where(user: current_user).first
  end

end
