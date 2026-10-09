require "nokogiri"
require "yaml"

root = File.expand_path("..", __dir__)
patents = YAML.load_file(File.join(root, "_data/profile.yml")).fetch("patents")
home = Nokogiri::HTML(File.read(File.join(root, "_site/index.html")))
cv = Nokogiri::HTML(File.read(File.join(root, "_site/cv/index.html")))
checks = 0
verify = lambda do |condition, message|
  raise message unless condition
  checks += 1
end

cards = home.css(".profile-patent")
verify.call(cards.length == patents.length, "A patent is missing from the homepage")
cards.zip(patents).each do |card, patent|
  title = patent.fetch("title")
  inventors = patent.fetch("inventors")
  names = inventors.map { |inventor| inventor.fetch("name") }.join(", ")
  verify.call(card.at_css("h3").text == title, "Patent title/order changed")
  authors = card.at_css(".profile-patent__inventors")
  verify.call(authors && authors.text.gsub(/\s+/, " ").strip == names, "Homepage patent inventors differ from data")
  highlighted = inventors.select { |inventor| inventor["highlight"] }.map { |inventor| inventor.fetch("name") }
  verify.call(authors.css("strong").map(&:text) == highlighted, "Homepage inventor emphasis changed")
  verify.call(card.at_css(".profile-patent__status").text == patent.fetch("status"), "Patent status changed")
  verify.call(card.css(".profile-patent__details").none? { |details| details.text.strip.empty? }, "Empty patent details should not leave a blank line")
  if patent["granted_date"]
    verify.call(card.text.include?("Granted #{patent.fetch('granted_date')}"), "Known grant date is missing")
  end

  cv_item = cv.css(".page__content li").find { |item| item.text.include?(title) }
  verify.call(cv_item && cv_item.text.include?("Inventors: #{names}."), "CV patent inventors differ from data")
  verify.call(cv_item.css("strong").map(&:text).include?("Y. Zheng"), "CV should emphasize Y. Zheng")
  if patent["granted_date"]
    verify.call(cv_item.text.include?("granted #{patent.fetch('granted_date')}"), "CV grant date differs from data")
  end
  numbers = %w[application_no patent_no publication_no].filter_map { |key| patent[key] }
  verify.call(numbers.any?, "Keep patent identifiers in the source data")
  numbers.each do |number|
    verify.call(!home.text.include?(number), "Patent identifier is still displayed on the homepage")
    verify.call(!cv.text.include?(number), "Patent identifier is still displayed on the CV")
  end
end

puts "#{checks} patent checks passed."
