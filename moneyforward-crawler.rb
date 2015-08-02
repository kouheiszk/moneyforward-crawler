require 'pry-byebug'
require 'nokogiri'
require 'capybara'
require 'capybara/poltergeist'
require 'yaml'

class MoneyforwardCrawler
  def initialize
    @config = YAML.load_file('config.yml')
    binding.pry
  end

  def retrieve
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 1000, phantomjs_options: ['--ignore-ssl-errors=true', '--ssl-protocol=any'])
    end
    Capybara.javascript_driver = :poltergeist
    Capybara.current_driver = :poltergeist
    Capybara.default_selector = :css

    session = Capybara::Session.new(:poltergeist)
    session.driver.headers = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12' }
    binding.pry
    session.instance_eval do
      visit 'https://moneyforward.com/users/sign_in'
      binding.pry
      fill_in 'sign_in_session_service[email]', with: @config['email']
      fill_in 'sign_in_session_service[password]', with: @config['password']
      click_on 'ログイン'
    end

    # # ログイン
    # agent.get('https://moneyforward.com/users/sign_in') do |page|
    #   puts page.title
    #   page.form_with(id: 'new_sign_in_session_service') do |form|
    #     form.field_with(name: 'sign_in_session_service[email]').value = @config['email']
    #     form.field_with(name: 'sign_in_session_service[password]').value = @config['password']
    #   end.submit
    # end
    # return unless agent.page.uri.to_s == 'https://moneyforward.com/'
    #
    # cookie = Mechanize::Cookie.new('cf_last_fetch_from_date', agent.page.uri.host, { value: '2014%2f08%2f02', domain: agent.page.uri.host, path: '/' })
    # agent.cookie_jar.add(agent.page.uri.host, cookie)
    #
    # # 家計簿に移動
    # agent.get('https://moneyforward.com/cf') do |page|
    #   puts page.title
    #   html = Nokogiri::HTML(page.body)
    #   rows = html.search('table#cf-detail-table > tbody > tr')
    #
    #   binding.pry
    # end

    puts 'Finish'
  end

  def self.execute
    crawler = MoneyforwardCrawler.new
    crawler.retrieve
  end
end

MoneyforwardCrawler.execute
