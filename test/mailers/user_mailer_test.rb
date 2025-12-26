require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  def setup
    @user = User.last
    
  end

  test "welcome" do
    mail = UserMailer.with(user: @user).welcome
    assert_equal "Bienvenido a AlmacenGT", mail.subject
    assert_equal [ "luis@almacengt.com" ], mail.to
    assert_equal [ "globaltrack@almacenGt.com" ], mail.from
    assert_match "Hey #{@user.username}", mail.body.encoded
  end
end
