class UserMailer < ActionMailer::Base
  default from: "Habit <welcome@habit.com>"

  def signup_email(user_id)
    @user = User.find user_id
    @twitter_message = "Get Rewarded. Habit"

    mail(:to => @user.email, :subject => "Thanks for signing up!")
  end
end
