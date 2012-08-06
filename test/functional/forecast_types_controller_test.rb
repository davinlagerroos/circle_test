require 'test_helper'

class ForecastTypesControllerTest < ActionController::TestCase
  setup do
    @forecast_type = forecast_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:forecast_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create forecast_type" do
    assert_difference('ForecastType.count') do
      post :create, forecast_type: {  }
    end

    assert_redirected_to forecast_type_path(assigns(:forecast_type))
  end

  test "should show forecast_type" do
    get :show, id: @forecast_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @forecast_type
    assert_response :success
  end

  test "should update forecast_type" do
    put :update, id: @forecast_type, forecast_type: {  }
    assert_redirected_to forecast_type_path(assigns(:forecast_type))
  end

  test "should destroy forecast_type" do
    assert_difference('ForecastType.count', -1) do
      delete :destroy, id: @forecast_type
    end

    assert_redirected_to forecast_types_path
  end
end
