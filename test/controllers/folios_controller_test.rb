require "test_helper"

class FoliosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get folios_index_url
    assert_response :success
  end

  test "should get show" do
    get folios_show_url
    assert_response :success
  end

  test "should get new" do
    get folios_new_url
    assert_response :success
  end

  test "should get edit" do
    get folios_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get folios_destroy_url
    assert_response :success
  end
end
