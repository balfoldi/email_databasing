class Scrapper

  def initialize
    @path = "db/email.json"
    @page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
    @session = GoogleDrive::Session.from_config("config.json")
    @email_sheet = @session.spreadsheet_by_key("1Xn5xeU3XOEjnlSbzy9cKuczm6fTno4j-xoMH9vgyn48").worksheets[0]
  end

  def create_town_url_array
    @town_url_array = []
    website = "https://annuaire-des-mairies.com/95/"
    @page.xpath('//td//a[contains(@href, 95)]').each do |el|
      el = el.to_s
      start_slice = el.index("95/") + 3
      stop_slice = el.index("\">") - 1
      el = el[start_slice..stop_slice]
      @town_url_array << website + el
    end
    puts @town_url_array
  end

  def create_town_email_hash
    email_array = []
    puts "LOADING..."
    @town_url_array.each do |page|
      page2 = Nokogiri::HTML(open(page))
      email = page2.css('table[1] tr[4] td[2]').text
      puts "#{email_array.length}-#{email}"
      email_array << email
    end
    town_array = []
    page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
    page.xpath('//td//a[contains(@href, 95)]').each do |el|
      el.text
      town_array << el.text
    end
    @data = []
    town_array.length.times do |i|
      mini_hash = Hash.new
      mini_hash[town_array[i]] = email_array[i]
      @data << mini_hash
    end
    @data.unshift({"MARIES" => "EMAIL"})
    puts @data
  end


  def save_as_json
    File.open(@path, "w") do |f|
      f.write(@data.to_json)
    end
  end

  def open_json
    @data = JSON.parse File.read(@path)
  end

  def save_as_spreadsheet
    @data.length.times do |i|
      @email_sheet[i+1, 1] = @data[i].keys
      @email_sheet[i+1, 2] = @data[i].values
    end
    @email_sheet.save
  end

  def save_as_csv
    data = File.write("db/emails.csv", (@data), mode: "w")
  end
end
