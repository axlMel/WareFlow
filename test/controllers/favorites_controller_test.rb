require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  setup do
    login
    @drill = products(:drill)
    @sim = products(:sim)

  end

  test "Should return my favorites" do
    get favorites_url


      assert_response :success
  end

  test "Should create favorite" do
    assert_difference('Favorite.count', 1) do
      post favorites_url(product_id: @drill.id)
    end

    assert_redirected_to product_path(@drill)
  end

  test "Should destroy favorite" do
    assert_difference('Favorite.count', -1) do
      delete favorite_url(@sim.id)
    end

    assert_redirected_to product_path(@sim)
  end



end
