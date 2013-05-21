require 'net/dns'
require 'net/http'

class Digger
  attr_reader :result, :domain

  SHOPIFY_IPS = ['204.93.213.40','204.93.213.41','204.93.213.42','204.93.213.43', '204.93.213.44', '204.93.213.45']

  def initialize(domain)
    @domain = domain
  end

  def follow_redirects
    idomain = domain
    response = nil
    while
      #puts "#{idomain}"
      uri = URI.parse(idomain)
      response = Net::HTTP.get_response(uri)
      if ["301", "302"].include?(response.code)
        idomain = response['location']
      else
        break
      end
    end
    return idomain, response
  end

  def ok?
    idomain, response = follow_redirects

    if response.code != "200"
      return false
    end

    res = self.class.dig(idomain)
    SHOPIFY_IPS.include?(res.answer.last.address.to_s)
  end

  def dig
    @result ||= self.class.dig(@domain)
  end

  def self.dig(domain)
    uri = URI.parse(domain)
    Net::DNS::Resolver.start(uri ? uri.host : domain)
  end
end

