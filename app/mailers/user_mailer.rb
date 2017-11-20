class UserMailer < ActionMailer::Base
  default from: "Habit <welcome@habit.com>"
  add_template_helper(ApplicationHelper)

  def signup_email(user_id)
    @user = User.find user_id

    mail(:to => @user.email, :subject => "Start sharing Habit to earn $100+ in Amazon eGift Cards")
  end
end
