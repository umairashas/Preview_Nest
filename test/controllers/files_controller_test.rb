require "test_helper"

class FilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get files_show_url
    assert_response :success
  end
end
