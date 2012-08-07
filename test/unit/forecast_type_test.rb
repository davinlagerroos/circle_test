require 'test_helper'

class ForecastTypeTest < ActiveSupport::TestCase
  test "the count is correct" do
    assert_equal 7, ForecastType.all.count
  end
  
  test "People are populated" do
    assert_equal 2000, $redis.scard('person_ids')
  end

  test "Random circle ci id is populated" do
    assert $redis.get('circleci_id').to_i > 0
  end
end
