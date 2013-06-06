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
    visited = []

    while true do
      if visited.include?(idomain)
        # did we ever visit a shopify domain?
        
        return nil, nil
      end
      visited << idomain

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
    domain, response = follow_redirects

    if response == nil or response.code != "200"
      return false
    end
    dns_ok?(domain)
  end

  def dns_ok?(domain)
    res = self.class.dig(domain)
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

