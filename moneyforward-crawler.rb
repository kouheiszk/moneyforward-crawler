require 'pry-byebug'
require 'mechanize'
require 'yaml'

class MoneyforwardCrawler
  def initialize
    @config = YAML.load_file('config.yml')
  end

  def retrieve
    agent = Mechanize.new
    # agent.agent.http.debug_output = $stderr

    # ログイン
    agent.get('https://moneyforward.com/users/sign_in') do |page|
      page.form_with(id: 'new_sign_in_session_service') do |form|
        form.field_with(name: 'sign_in_session_service[email]').value = @config['email']
        form.field_with(name: 'sign_in_session_service[password]').value = @config['password']
      end.submit
    end
    return unless agent.page.uri.to_s == 'https://moneyforward.com/'

    # 家計簿に移動
    agent.get('https://moneyforward.com/cf') do |page|
      html = Nokogiri::HTML(page.body)
      year_node = html.search('div#calendar')
      month_node = html.search('div#calendar')

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
