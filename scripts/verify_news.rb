require "jekyll"
require "nokogiri"
require "yaml"
require "date"

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
  date = item.fetch("date")
  verify.call(date.is_a?(String) && date.match?(/\A\d{4}-(0[1-9]|1[0-2])(-\d{2})?\z/), "News dates must be quoted YYYY-MM or YYYY-MM-DD strings")
  Date.iso8601(date.length == 7 ? "#{date}-01" : date)
end
expected = entries.sort_by { |item| item.fetch("date") }.reverse
verify.call(home.css("#news time").map { |time| time["datetime"] } == expected.map { |item| item.fetch("date") }, "Homepage news dates/order differ from data")
verify.call(home.css("#news .profile-news-list > li").length == entries.length, "All news must remain in the scrollable list")
verify.call(home.css("#news details").empty?, "News should scroll instead of collapsing")
verify.call(home.css("#news a[href^='#']").all? { |link| home.css("[id]").count { |element| element["id"] == link["href"].delete_prefix("#") } == 1 }, "News contains a missing or duplicate anchor target")
if entries.any?
  verify.call(home.at_css(".profile-news-scroll[tabindex='0'][role='region'][aria-label='News list']"), "News scrolling needs a named keyboard target")
  sections = home.css(".profile-hero, .profile-news, .profile-section--publications")
  verify.call(sections.map { |section| section["class"].split.last } == ["profile-hero", "profile-news", "profile-section--publications"], "News must sit between the introduction and publications")
end

verify.call(home.css(".profile-section-title").map(&:text).take(3) == ["News", "Education", "Publications"], "Education must sit between News and Publications")

%w[index.html publications/index.html].each do |path|
  page = Nokogiri::HTML(File.read(File.join(root, "_site", path)))
  scroll = page.at_css(".profile-publication-scroll[tabindex='0'][role='region'][aria-label='Publication list']")
  verify.call(scroll, "Missing keyboard-accessible publication scroll area: #{path}")
  page.css(".profile-scroll").each do |region|
    id = region["id"]
    verify.call(id && page.css("[id='#{id}']").length == 1, "Scroll region needs a unique identifier: #{path}")
    hints = page.css(".profile-scroll-hint[data-scroll-target='#{id}']")
    verify.call(hints.length == 1, "Scroll region needs exactly one indicator: #{path} #{id}")
    hint = hints.first
    verify.call(hint.key?("hidden"), "Only show scroll hints after detecting overflow")
    verify.call(hint["title"] == "Scroll within this list", "Scroll icon needs a tooltip")
    verify.call(hint["aria-hidden"] == "true", "Decorative scroll icon must not change the accessible heading")
    verify.call(hint.at_css(".fa-arrows-up-down"), "Scroll indicator must use the existing icon set")
  end
  publications = profile.fetch("publications").reject { |paper| paper["hidden"] == true }.sort_by { |paper| paper.fetch("sort_month") }.reverse
  verify.call(scroll.css(".profile-publication h2, .profile-publication h3").map(&:text) == publications.map { |paper| paper.fetch("title") }, "Scrolling must retain all visible publications in order: #{path}")
  scroll.css(".profile-publication").zip(publications).each do |card, paper|
    verify.call(card.css(".profile-publication__meta a").empty?, "Venue labels must remain plain text: #{path}")
    verify.call(card.at_css(".profile-publication__meta").text == paper.fetch("venue"), "Venue label changed: #{path}")
    verify.call(card.css(".profile-link-row a").map { |link| [link.text, link["href"]] } == paper.fetch("links", []).map { |link| [link.fetch("label"), link.fetch("url")] }, "Paper and conference links must stay in the resource row: #{path}")
  end
end

cv = Nokogiri::HTML(File.read(File.join(root, "_site/cv/index.html")))
profile.fetch("publications").reject { |paper| paper["hidden"] }.each do |paper|
  item = cv.css(".page__content li").find { |entry| entry.text.include?(paper.fetch("title")) }
  verify.call(item, "CV publication missing")
  verify.call(item.at_css("strong").text == paper.fetch("venue") && item.css("strong a").empty?, "CV venue labels must remain plain text")
  verify.call(item.css("a").map { |link| [link.text, link["href"]] } == paper.fetch("links", []).map { |link| ["[#{link.fetch('label')}]", link.fetch("url")] }, "CV resource links differ from profile data")
end

# Exercise empty, long and mixed-precision lists without changing profile data.
site = Jekyll::Site.new(Jekyll.configuration("source" => root, "quiet" => true))
template = Liquid::Template.parse("{% include profile-news.html news=entries %}")
fixtures = (1..5).map do |month|
  { "date" => "2026-#{format('%02d', month)}", "text" => "Update #{month}: **Accepted** with [details](#vlan)." }
end
dated = ["2026-05-01", "2026-09", "2026-09-26"].map do |date|
  { "date" => date, "text" => "One paper **accepted** with [details](#vlan)." }
end
[nil, [], fixtures.take(1), fixtures.take(3), fixtures.take(4), fixtures, dated].each do |items|
  rendered = template.render!({ "entries" => items }, registers: { site: site })
  page = Nokogiri::HTML.fragment(rendered)
  count = Array(items).length
  verify.call(page.css("#news").length == (count.zero? ? 0 : 1), "Empty or missing news should hide the section")
  verify.call(page.css(".profile-news-list li").length == count, "News entry missing or duplicated")
  verify.call(page.css(".profile-news-scroll > ol > li").length == count, "News must not be truncated")
  verify.call(page.css("time").map { |time| time["datetime"] } == Array(items).map { |item| item["date"] }.sort.reverse, "News is not newest first")
  verify.call(page.css("details").empty?, "Unexpected collapsed archive")
  next if count.zero?

  labels = Array(items).sort_by { |item| item["date"] }.reverse.map do |item|
    date = item["date"]
    Date.iso8601(date.length == 7 ? "#{date}-01" : date).strftime("[%b %Y]")
  end
  verify.call(page.css("time").map(&:text) == labels, "Dates must display consistent month labels")
  verify.call(page.at_css(".profile-news-scroll[tabindex='0'][role='region'][aria-label='News list']"), "News list must be keyboard-scrollable")
  verify.call(page.css(".profile-news__text strong").length == count, "Markdown emphasis not rendered")
  verify.call(page.css(".profile-news__text a[href='#vlan']").length == count, "Markdown links not rendered")
end

puts "#{checks} news checks passed."
