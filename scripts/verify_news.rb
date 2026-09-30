require "jekyll"
require "nokogiri"
require "yaml"

root = File.expand_path("..", __dir__)
profile = YAML.load_file(File.join(root, "_data/profile.yml"))
home = Nokogiri::HTML(File.read(File.join(root, "_site/index.html")))
checks = 0
verify = lambda do |condition, message|
  raise message unless condition
  checks += 1
end

entries = profile.fetch("news", [])
entries.each do |item|
  verify.call(item.fetch("date").match?(/\A\d{4}-(0[1-9]|1[0-2])\z/), "News dates must be quoted YYYY-MM strings")
end
expected = entries.sort_by { |item| item.fetch("date") }.reverse
verify.call(home.css("#news time").map { |time| time["datetime"] } == expected.map { |item| item.fetch("date") }, "Homepage news dates/order differ from data")
verify.call(home.css("#news > .profile-news-list > li").length == [entries.length, 3].min, "Homepage must show at most three recent entries")
verify.call(home.css("#news details").length == (entries.length > 3 ? 1 : 0), "Archive should only appear when needed")
verify.call(home.css("#news a[href^='#']").all? { |link| home.css("[id]").count { |element| element["id"] == link["href"].delete_prefix("#") } == 1 }, "News contains a missing or duplicate anchor target")
if entries.any?
  sections = home.css(".profile-hero, .profile-news, .profile-section--publications")
  verify.call(sections.map { |section| section["class"].split.last } == ["profile-hero", "profile-news", "profile-section--publications"], "News must sit between the introduction and publications")
end

# Exercise archive boundaries without changing the profile data or writing a site.
site = Jekyll::Site.new(Jekyll.configuration("source" => root, "quiet" => true))
template = Liquid::Template.parse("{% include profile-news.html news=entries %}")
fixtures = (1..5).map do |month|
  { "date" => "2026-#{format('%02d', month)}", "text" => "Update #{month}: **Accepted** with [details](#vlan)." }
end
[nil, [], fixtures.take(1), fixtures.take(3), fixtures.take(4), fixtures].each do |items|
  rendered = template.render!({ "entries" => items }, registers: { site: site })
  page = Nokogiri::HTML.fragment(rendered)
  count = Array(items).length
  verify.call(page.css("#news").length == (count.zero? ? 0 : 1), "Empty or missing news should hide the section")
  verify.call(page.css(".profile-news-list li").length == count, "News entry missing or duplicated")
  verify.call(page.css("#news > ol > li").length == [count, 3].min, "Wrong recent entry count")
  verify.call(page.css("time").map { |time| time["datetime"] } == Array(items).map { |item| item["date"] }.sort.reverse, "News is not newest first")
  verify.call(page.css("details").length == (count > 3 ? 1 : 0), "Wrong archive visibility")
  next if count.zero?

  verify.call(page.at_css("time").text.match?(/\A[A-Z][a-z]{2} 2026\z/), "Invalid month label")
  verify.call(page.css(".profile-news__text strong").length == count, "Markdown emphasis not rendered")
  verify.call(page.css(".profile-news__text a[href='#vlan']").length == count, "Markdown links not rendered")
  next unless count > 3

  verify.call(page.at_css("details")["open"].nil?, "Earlier news should start collapsed")
  verify.call(page.at_css("details > summary"), "Archive needs a native keyboard-accessible summary")
  verify.call(page.css("details ol[start='4'] li").length == count - 3, "Wrong archived entry count")
end

puts "#{checks} news checks passed."
