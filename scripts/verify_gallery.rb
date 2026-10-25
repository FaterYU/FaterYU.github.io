require "jekyll"
require "nokogiri"
require "yaml"
require "date"

root = File.expand_path("..", __dir__)
gallery = YAML.load_file(File.join(root, "_data/gallery.yml"))
checks = 0
verify = lambda do |condition, message|
  raise message unless condition
  checks += 1
end

%w[index.html publications/index.html gallery/index.html cv/index.html projects/index.html].each do |path|
  page = Nokogiri::HTML(File.read(File.join(root, "_site", path)))
  nav = page.at_css(".masthead")
  verify.call(nav.css("a[href='/projects/']").empty?, "Projects must stay hidden from navigation: #{path}")
  verify.call(nav.css("a[href='/gallery/']").length == 1, "Gallery navigation link missing: #{path}")
end

page = Nokogiri::HTML(File.read(File.join(root, "_site/gallery/index.html")))
events = gallery.fetch("events")
verify.call(page.css("h1").map(&:text) == ["Gallery"], "Gallery needs one page heading")
verify.call(page.css(".profile-gallery-event").map { |event| event["id"] } == events.map { |event| event.fetch("id") }, "Gallery event order differs from data")
verify.call(events.map { |event| event.fetch("id") }.uniq.length == events.length, "Gallery event IDs must be unique")
events.each do |event|
  section = page.at_css("##{event.fetch('id')}")
  verify.call(section.at_css("h2").text == event.fetch("title"), "Event title differs from data")
  photos = event.fetch("photos", [])
  verify.call(section.css(".profile-gallery-photo").length == photos.length, "Event photo count differs from data")
  verify.call(section.css(".profile-gallery-empty").length == (photos.empty? ? 1 : 0), "Only empty events need a placeholder")
  if event["description"] || event["date"] || event["location"]
    details = section.at_css(".profile-gallery-event__details")
    verify.call(details && section.element_children.last == details, "Event description and metadata must follow the photos")
    verify.call(details.at_css("p"), "Event description is missing") if event["description"]
    if event["date"]
      date = Date.iso8601(event.fetch("date"))
      time = details.at_css("time")
      verify.call(time && time["datetime"] == event.fetch("date") && time.text == date.strftime("%B %-d, %Y"), "Event date differs from data")
    end
    verify.call(details.css(".profile-gallery-event__meta span").map(&:text).include?(event["location"]), "Event location differs from data") if event["location"]
  end
  photos.each do |photo|
    verify.call(!photo.fetch("alt").strip.empty?, "Photos need meaningful alternative text")
    verify.call(File.file?(File.join(root, photo.fetch("src").delete_prefix("/"))), "Gallery photo file is missing")
  end
end

# Exercise the future photo state without publishing sample images.
site = Jekyll::Site.new(Jekyll.configuration("source" => root, "quiet" => true))
template = Liquid::Template.parse('{% include profile-gallery-event.html event=event %}')
fixtures = [[], [{ "src" => "/images/profile-zhengyu.jpg", "alt" => 'A photo with "quotes" & details', "caption" => "Example <caption>" }]]
fixtures.each do |photos|
  event = { "id" => "test-event", "title" => "Test event", "description" => "We organized a [workshop](https://example.org/).", "photos" => photos }
  fragment = Nokogiri::HTML.fragment(template.render!({ "event" => event }, registers: { site: site }))
  verify.call(fragment.css(".profile-gallery-photo").length == photos.length, "All photos must be rendered")
  verify.call(fragment.css(".profile-gallery-empty").length == (photos.empty? ? 1 : 0), "Empty state does not match photos")
  verify.call(fragment.at_css(".profile-gallery-event__details a")["href"] == "https://example.org/", "Event description must retain its Markdown link")
  verify.call(fragment.css(".profile-gallery-event__header p, .profile-gallery-event__header a").empty?, "Keep descriptive text below the photos")
  verify.call(fragment.css(".profile-gallery-event__meta").empty?, "Missing dates and locations must not render empty metadata")
  photos.zip(fragment.css(".profile-gallery-photo")).each do |photo, figure|
    image = figure.at_css("img")
    link = figure.at_css("a.image-popup")
    verify.call(image["alt"] == photo.fetch("alt"), "Alternative text must be escaped correctly")
    verify.call(image["loading"] == "lazy" && image["decoding"] == "async", "Gallery photos should load lazily")
    verify.call(link && link["href"] == image["src"], "Photo must open the matching full-size image")
    verify.call(link["aria-label"] == "View photo: #{photo.fetch('alt')}", "Photo preview needs an accessible name")
    verify.call(figure.at_css("figcaption").text == photo.fetch("caption"), "Photo captions must be escaped correctly")
  end
end

puts "#{checks} gallery checks passed."
