require "test_helper"

class FetchCountryServiceTest < ActiveSupport::TestCase
	test "it should return ca with a valid Ip" do
		stub_request(:get, "http://ip-api.com/json/24.48.0.1").
		to_return(status: 200, body: {
			status: "success",
			countryCode: "CA"
		}.to_json, headers: {})
		assert_equal(FetchCountryService.new("24.48.0.1").perform, "ca")
	end

	test "it should return ca with an invalid Ip" do
		stub_request(:get, "http://ip-api.com/json/fakeIp").
		to_return(status: 200, body: {
			status: "fail"
		}.to_json, headers: {})
		assert_nil(FetchCountryService.new("fakeIp").perform)
	end
end
