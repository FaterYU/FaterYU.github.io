require "nokogiri"
require "yaml"

root = File.expand_path("..", __dir__)
author = YAML.load_file(File.join(root, "_config.yml")).fetch("author")
checks = 0
verify = lambda do |condition, message|
  raise message unless condition
  checks += 1
end

%w[index.html publications/index.html cv/index.html projects/index.html].each do |path|
  page = Nokogiri::HTML(File.read(File.join(root, "_site", path)))
  verify.call(page.css("h1").length == 1, "Missing or duplicated page identity: #{path}")
  verify.call(page.at_css(".author__avatar img[alt]"), "Sidebar portrait missing: #{path}")
  verify.call(page.at_css("#author-links"), "Sidebar contact links missing: #{path}")
  if path != "index.html"
    verify.call(page.css(".sidebar .author__name").length == 1, "Inner pages must retain the author identity: #{path}")
    next
  end

  verify.call(page.css(".sidebar .author__content, .profile-eyebrow").empty?, "Homepage identity should not be repeated")
  actions = page.at_css(".profile-actions")
  verify.call(actions, "Missing contact actions")
  verify.call(actions.css("a[href='#publications']").length == 1, "Missing publication jump link")
  verify.call(actions.css("a").any? { |link| link["href"] == "mailto:#{author.fetch('email')}" }, "Missing email link")
  scholar = actions.at_css(".profile-action--mobile[aria-label='Google Scholar']")
  verify.call(scholar && scholar["href"] == author.fetch("googlescholar"), "Missing mobile Scholar link")
  menu = actions.at_css("details.profile-contact-menu")
  verify.call(menu && menu.at_css("summary"), "More must remain a native keyboard-accessible disclosure")
  destinations = {
    "GitHub" => "https://github.com/#{author.fetch('github')}",
    "LinkedIn" => "https://www.linkedin.com/in/#{author.fetch('linkedin')}",
    "ORCID" => author.fetch("orcid"),
    "Website" => author.fetch("uri"),
    "bilibili" => "https://space.bilibili.com/#{author.fetch('bilibili')}",
    "RedNote" => author.fetch("xiaohongshu")
  }
  links = menu.css("a").to_h { |link| [link.text, link["href"]] }
  destinations.each do |label, url|
    verify.call(links[label] == url, "Mobile #{label} link missing or changed")
  end
end

profile = YAML.load_file(File.join(root, "_data/profile.yml"))
home = Nokogiri::HTML(File.read(File.join(root, "_site/index.html")))
sources = YAML.load_file(File.join(root, "images/organizations/sources.yml"))
{
  "#education .profile-timeline > li" => profile.fetch("education"),
  "#internship .profile-internship-list > li" => profile.fetch("internships").fetch("items")
}.each do |selector, entries|
  rows = home.css(selector)
  verify.call(rows.length == entries.length, "Affiliation entries missing: #{selector}")
  rows.zip(entries).each do |row, entry|
    text = row.text.gsub(/\s+/, " ")
    %w[title text period detail].each do |key|
      next unless entry[key]
      verify.call(text.include?(entry[key]), "Affiliation #{key} changed: #{entry.inspect}")
    end
    logo = row.at_css(".profile-organization-logo img")
    path = entry.fetch("logo")
    verify.call(logo && logo["src"] == path, "Affiliation logo missing: #{path}")
    verify.call(logo["alt"] == "", "Logos must not repeat adjacent organization names")
    verify.call(logo["width"] && logo["height"], "Reserve logo dimensions: #{path}")
    verify.call(logo["loading"] == "lazy", "Lazy-load below-the-fold logos: #{path}")
    %w[. _site].each do |directory|
      asset = File.join(root, directory, path.delete_prefix("/"))
      verify.call(File.file?(asset) && File.size(asset) > 0, "Local logo file missing: #{asset}")
    end
    verify.call(sources.key?(File.basename(path)), "Record official logo source: #{path}")
  end
end

puts "#{checks} profile layout checks passed."
