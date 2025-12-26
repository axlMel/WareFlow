require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  def setup
    login
  end
  test 'render a list of products' do
    get products_path

    assert_response :success
    assert_select '.product', 12
    assert_select '.category', 10
  end

  test 'render a list of products filtered by category' do
    get products_path(category_id: categories(:device).id)

    assert_response :success
    assert_select '.product', 4
  end

  test 'render a list of products filtered by min_stock and max_stock' do
    get products_path(min_stock: 5, max_stock: 15)

    assert_response :success
    assert_select '.product', 2
    assert_select 'h2', 'Tornillos'
  end

  test 'search a product filtered by query_text' do
    get products_path(query_text: 'Tornillos')

    assert_response :success
    assert_select '.product', 1
    assert_select 'h2', 'Tornillos'
  end

  test 'sort product by expensive prices first' do
    get products_path(order_by: 'expensive')

    assert_response :success
    assert_select '.product', 12
    assert_select '.products .product:first-child h2', 'Antena GSM'
  end

  test 'sort product by expensive cheapest prices first' do
    get products_path(order_by: 'cheapest')

    assert_response :success
    assert_select '.product', 12
    assert_select '.products .product:first-child h2', 'Tornillos'
  end

  test 'render a detailed product page' do
    get product_path(products(:wire))

    assert_response :success
    assert_select '.title', 'Cable'
    assert_select '.description', '10 mts de cable awd14'
    assert_select '.price', '30$'
  end

  test 'render a new product form' do
    get new_product_path

    assert_response :success
    assert_select 'form'
  end

  test 'allows to create a new proyect' do
    post products_path, params: {
      product: {
        title: 'Cable',
        description: '10 mts de cable awd14',
        price: 30,
        category_id: categories(:device).id
      }
    }

    assert_redirected_to products_path
    assert_equal flash[:notice], 'Tu producto se ha creado correctamente'
  end

  test 'does not allow to create a new proyect with empty fields' do
    post products_path, params: {
      product: {
        title: '',
        description: '10 mts de cable awd14',
        price: 30,
      }
    }

    assert_response :unprocessable_entity
  end

  test 'render an edit product form' do
    get edit_product_path(products(:wire))

    assert_response :success
    assert_select 'form'
  end

  test 'allows to update a new product' do
    patch product_path(products(:wire)), params: {
      product: {
        price: 60
      }
    }

    assert_redirected_to products_path
    assert_equal flash[:notice], 'Tu producto se ha actualizado correctamente'
  end

  test 'does not allow to update a new product with an invalid field' do
    patch product_path(products(:wire)), params: {
      product: {
        price: nil
      }
    }

    assert_response :unprocessable_entity
  end

  test 'can delete products' do
    assert_difference('Product.count', -1) do
      delete product_path(products(:wire))
    end

    assert_redirected_to products_path
    assert_equal flash[:notice], 'Tu producto se ha eliminado correctamente'
  end
end
