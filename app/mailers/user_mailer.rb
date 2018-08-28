class UserMailer < ActionMailer::Base
  default from: "Habit <support@habit.com>"
  add_template_helper(ApplicationHelper)

  def signup_email(user_id)
    @user = User.find user_id

    mail(:to => @user.email, :subject => "Start sharing Habit to earn Amazon eGift Cards")
  end
end
