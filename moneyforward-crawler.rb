require 'pry-byebug'
require 'nokogiri'
require 'mechanize'
require 'yaml'

class MoneyforwardCrawler
  def initialize
    @config = YAML.load_file('config.yml')
  end

  def retrieve
    agent = Mechanize.new do |agent|
      agent.log = Logger.new($stdout)
      agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12'
    end

    site_url = 'https://moneyforward.com'
    uri = URI.parse(site_url)

    # ログイン
    agent.get('https://moneyforward.com/users/sign_in') do |page|
      puts page.title
      page.form_with(id: 'new_sign_in_session_service') do |form|
        form.field_with(name: 'sign_in_session_service[email]').value = @config['email']
        form.field_with(name: 'sign_in_session_service[password]').value = @config['password']
      end.submit
    end
    return unless agent.page.uri.to_s == 'https://moneyforward.com/'

    # 家計簿に移動

    cookie = Mechanize::Cookie.new('cf_last_fetch_from_date', uri.host, { value: '2014%2F09%2F01', domain: uri.host, path: '/' })
    agent.cookie_jar.add(uri.host, cookie)

    agent.get('https://moneyforward.com/cf') do |page|

      puts page.title
      html = Nokogiri::HTML(page.body)
      rows = html.search('table#cf-detail-table > tbody > tr')

      binding.pry
    end

    puts 'Finish'
  end

  def self.execute
    crawler = MoneyforwardCrawler.new
    crawler.retrieve
  end
end

MoneyforwardCrawler.execute
