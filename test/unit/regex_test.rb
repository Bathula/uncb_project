require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RegexTest < ActiveSupport::TestCase
  R = Regex

  # Test R::REGEX_EMAIL

  GOOD_EMAILS = [
    "bill@microsoft.com",
    "bill.gates@netcentrics.com",
    "bill_gates@netcentrics.com",
    "bill-gates@netcentrics.com",
    "bill@host.microsoft.com",
    "bill@microsoft.org",
    "bill@microsoft.edu",
    "bill@microsoft.ca",
    ".bill@microsoft.com",
    "bill+gates@microsoft.com",
    "bill@10.0.0.1",
    "bill@255.255.255.255",
    "foo+bar-baz@example.com"
    ]

  BAD_EMAILS = [
    "bill",
    "bill@",
    "bill@com",
    "ab@bc@de",
    " ",
    "",
    ]

  def test_regex_email
    GOOD_EMAILS.each {|email| assert email =~ R::REGEX_EMAIL }
    BAD_EMAILS.each {|email| assert email !~ R::REGEX_EMAIL }
  end

  # Test R::REGEX_PHONE

  # Test number followed by pieces that should be parsed out
  # area code, exchange, number, extension
  GOOD_PHONE_NUMBERS = [
    ["(919) 467-2700", "919", "467", "2700", nil],
    ["1(919) 467-2700", "919", "467", "2700", nil],
    ["1 (919) 467-2700", "919", "467", "2700", nil],
    ["1-(919) 467-2700", "919", "467", "2700", nil],
    ["1 - (919) 467-2700", "919", "467", "2700", nil],
    ["919-467-2700", "919", "467", "2700", nil],
    ["1-919-467-2700", "919", "467", "2700", nil],
    ["919.467.2700", "919", "467", "2700", nil],
    ["1.919.467.2700", "919", "467", "2700", nil],
    ["(919) 467-2700 x123", "919", "467", "2700", "x123"],
    ["1 (919) 467-2700 x123", "919", "467", "2700", "x123"],
    ["(919) 467-2700 x12345", "919", "467", "2700", "x12345"],
    ["(919) 467-2700 Ext. 12345", "919", "467", "2700", "Ext. 12345"],
    ["(919)467-2700 Ext. 12345", "919", "467", "2700", "Ext. 12345"],
    ["9194672700", "919", "467", "2700", nil],
    ["(919) 467-2700 x 12345", "919", "467", "2700", "x 12345"],
    ["9194672700 x123", "919", "467", "2700", "x123"],
    ["(919)4672700", "919", "467", "2700", nil],
    ["9194672700x123", "919", "467", "2700", "x123"],
    ["19194672700x123", "919", "467", "2700", "x123"],
    ]

  BAD_PHONE_NUMBERS = [
    "91946727001",
    "(919) abc-2700",
    "919) 467-2700",
    "(919 467-2700",
    "",
    " ",
    ]

  def test_format_phone
    assert_equal('919-555-1212', R.format_phone('9195551212'))
    assert_equal('919-555-1212', R.format_phone('919-555-1212'))
    assert_equal('919-555-1212', R.format_phone('(919) 555-1212'))
    assert_equal('919-555-1212', R.format_phone('(919)555-1212'))
    assert_equal('919-555-1212', R.format_phone('919.555.1212'))

    assert_equal('919.555.1212', R.format_phone('9195551212', '.'))
    assert_equal('919.555.1212', R.format_phone('919-555-1212', '.'))
    assert_equal('919.555.1212', R.format_phone('(919) 555-1212', '.'))
    assert_equal('919.555.1212', R.format_phone('(919)555-1212', '.'))
    assert_equal('919.555.1212', R.format_phone('919.555.1212', '.'))

    assert_equal('9195551212', R.format_phone('9195551212', ''))
    assert_equal('9195551212', R.format_phone('919-555-1212', ''))
    assert_equal('9195551212', R.format_phone('(919) 555-1212', ''))
    assert_equal('9195551212', R.format_phone('(919)555-1212', ''))
    assert_equal('9195551212', R.format_phone('919.555.1212', ''))
  end

  def test_parse_invalid_phone
    assert_nil(R.parse_phone('asdf'))
  end

  def test_phone_parse
    area_code, exchange, number, extension = R.parse_phone("614-555-1212")
    assert_equal '614', area_code
    assert_equal '555', exchange
    assert_equal '1212', number
    assert_equal nil, extension
    area_code, exchange, number, extension = R.parse_phone("(614) 555-1212")
    assert_equal '614', area_code
    assert_equal '555', exchange
    assert_equal '1212', number
    assert_equal nil, extension
    area_code, exchange, number, extension = R.parse_phone("(614) 555-1212 x1234")
    assert_equal '614', area_code
    assert_equal '555', exchange
    assert_equal '1212', number
    assert_equal 'x1234', extension
    area_code, exchange, number, extension = R.parse_phone("(614) 555-1212x1234")
    assert_equal '614', area_code
    assert_equal '555', exchange
    assert_equal '1212', number
    assert_equal 'x1234', extension

    assert_nil(R.parse_phone("(614) 555-12121234"))
  end

  def test_regex_phone
    GOOD_PHONE_NUMBERS.each do |phone, area, exchange, number, extension|
      assert phone =~ R::REGEX_PHONE
      a, exch, n, ext = R.parse_phone(phone)
      assert_equal area, a
      assert_equal exchange, exch
      assert_equal number, n
      assert_equal extension, ext
    end
    BAD_PHONE_NUMBERS.each {|phone| assert phone !~ R::REGEX_PHONE }
  end

end
