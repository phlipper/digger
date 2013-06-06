require 'test_helper'
require 'mocha/setup'

class TestDigger < Test::Unit::TestCase
  def test_can_create_digger_objects
    obj = Digger.new("http://denydesign.com")
    obj.dig
    assert_equal "http://denydesign.com", obj.domain
    assert_equal 1, obj.result.answer.length
    assert_equal 'A', obj.result.answer[0].type
    assert_equal "50.63.202.1", obj.result.answer[0].address.to_s
  end

  def test_ok_works_for_shop_url
    obj = Digger.new("http://www.denydesigns.com")
    assert obj.ok?
  end

  def test_ok_fails_for_non_shopify_url
    obj = Digger.new("http://asdf.com")
    assert !obj.ok?
  end

  def test_follow_redirects_returns_last_in_chain
    obj = Digger.new("http://denydesign.com")
    last = obj.follow_redirects
  end

  def test_ok_works_for_redirect
    obj = Digger.new("http://denydesign.com")
    assert obj.ok?
  end

  def test_ok_works_for_redirect_loop
    mock1 = mock(:code => "301", :[] => "http://asdf2.com")
    mock2 = mock(:code => "301", :[] => "http://asdf.com")
    uri1 = URI.parse("http://asdf.com")
    uri2 = URI.parse("http://asdf2.com")
    Net::HTTP.expects(:get_response).with(uri1).returns(mock1).once
    Net::HTTP.expects(:get_response).with(uri2).returns(mock2).once

    obj = Digger.new("http://asdf.com")
    assert !obj.ok?
  end

  def test_redirect_loop_finds_shopify_in_loop
    mock1 = mock(:code => "301", :[] => "http://asdf2.com")
    mock2 = mock(:code => "301", :[] => "http://asdf3.com")
    mock3 = mock(:code => "301", :[] => "http://asdf.com")
    uri1 = URI.parse("http://asdf.com")
    uri2 = URI.parse("http://asdf2.com")
    uri3 = URI.parse("http://asdf3.com")

    Net::HTTP.expects(:get_response).with(uri1).returns(mock1).once
    Net::HTTP.expects(:get_response).with(uri2).returns(mock2).once
    Net::HTTP.expects(:get_response).with(uri3).returns(mock3).once
    Digger.expects(:dig_ok?).with("http://asdf3.com").returns(false)
    Digger.expects(:dig_ok?).with("http://asdf2.com").returns(true)

    obj = Digger.new("http://asdf.com")
    assert !obj.ok?

    assert_equal "Set your primary domain to http://asdf2.com in the Shopify2 Domains Admin", obj.message
  end
end
