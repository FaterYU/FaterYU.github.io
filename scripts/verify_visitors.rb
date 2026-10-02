require "nokogiri"
require "uri"

root = File.expand_path("..", __dir__)
checks = 0
verify = lambda do |condition, message|
  raise message unless condition
  checks += 1
end

%w[index.html publications/index.html cv/index.html projects/index.html].each do |path|
  page = Nokogiri::HTML(File.read(File.join(root, "_site", path)))
  widgets = page.css(".visitor-map")
  verify.call(widgets.length == 1, "Expected one visitor widget: #{path}")
  widget = widgets.first
  link = widget.at_css("a")
  verify.call(link && link["href"] == "https://mapmyvisitors.com/web/1bz1p", "Wrong statistics destination: #{path}")
  verify.call(link["aria-label"] && link["rel"].split.include?("noopener"), "Missing accessible, safe statistics link: #{path}")
  images = widget.css("img")
  verify.call(images.length == 1, "Expected one tracking image: #{path}")
  image = images.first
  url = URI(image["src"])
  query = URI.decode_www_form(url.query).to_h
  verify.call(url.scheme == "https" && url.host == "mapmyvisitors.com" && url.path == "/map.png", "Wrong image endpoint: #{path}")
  verify.call(query["d"] == "FnPAPOqHpKu-h9TlT8uRufYFE4wQmiUzYBJKHL6ICJc", "Wrong image widget ID: #{path}")
  verify.call(image["loading"] == "eager", "Counting must not depend on scrolling: #{path}")
  verify.call(image["width"] == "180" && image["height"] == "88", "Map must reserve its layout dimensions: #{path}")
  verify.call(!image["alt"].to_s.empty?, "Missing map alternative text: #{path}")
  verify.call(image["referrerpolicy"] == "strict-origin-when-cross-origin", "Map should only send the site origin: #{path}")
  verify.call(widget.css("script, iframe").empty? && page.css(".visitor-globe").empty?, "Legacy Globe embed remains: #{path}")
end

javascript = File.read(File.join(root, "assets/js/main.min.js"))
verify.call(!javascript.include?("visitor-globe"), "Rebuild JavaScript to remove the legacy loader")
verify.call(!File.exist?(File.join(root, "_site/assets/html/visitor-globe.html")), "Legacy Globe page remains in build")
puts "#{checks} visitor widget checks passed."
