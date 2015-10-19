require 'test_helper'

class GuidesControllerTest < ActionController::TestCase
  setup do
    @guide = guides(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:guides)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create guide" do
    assert_difference('Guide.count') do
      post :create, guide: { answer: @guide.answer, group: @guide.group, qtype: @guide.qtype, question: @guide.question, score: @guide.score }
    end

    assert_redirected_to guide_path(assigns(:guide))
  end

  test "should show guide" do
    get :show, id: @guide
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @guide
    assert_response :success
  end

  test "should update guide" do
    put :update, id: @guide, guide: { answer: @guide.answer, group: @guide.group, qtype: @guide.qtype, question: @guide.question, score: @guide.score }
    assert_redirected_to guide_path(assigns(:guide))
  end

  test "should destroy guide" do
    assert_difference('Guide.count', -1) do
      delete :destroy, id: @guide
    end

    assert_redirected_to guides_path
  end
end
