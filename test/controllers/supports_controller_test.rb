require "test_helper"

class SupportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get supports_index_url
    assert_response :success
  end

  test "should get show" do
    get supports_show_url
    assert_response :success
  end

  test "should get new" do
    get supports_new_url
    assert_response :success
  end

  test "should get edit" do
    get supports_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get supports_destroy_url
    assert_response :success
  end
end
