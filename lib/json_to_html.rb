require 'json'

class String
  def add_spans!(re, color)
    gsub!(re) { |match| %Q(<span style="color:#{color}">#{match}</span>) }
  end
end

$j2h = proc do |json_string, colors = {}|

  bracket   = colors[:bracket]   || '#009900'
  delimiter = colors[:delimiter] || '#339933'
  other     = colors[:other]     || '#CC0000'
  text      = colors[:text]      || '#3366CC'

  colon = '---colon---'
  comma = '---comma---'

  # Parse to ruby object first to make sure it is well-formed json
  pretty_string = JSON.pretty_generate(JSON.parse(json_string))

  # Substitute so that ':' in span styles are not wrapped in spans
  pretty_string.gsub!(/\":/, "\"#{colon}")

  # Substitute commas in quoted text so they are not treated as delimiters
  pretty_string.gsub!(/(\")(?:\1|.)*?\1/) { |match| match.gsub(/,/, comma) }

  pretty_string.add_spans!(/(\")(?:\1|.)*?\1/, text)
  pretty_string.add_spans!(colon, delimiter).gsub!(colon, ':')
  pretty_string.add_spans!(/,/, delimiter).gsub!(comma, ',')
  pretty_string.add_spans!(/[{}\[\]]/, bracket)

  # All the results are wrapped in a span to set the color of all other items not directly wrapped in a span.
  %Q(<pre style="font-size:16px;font-family:monospace,Courier!important;vertical-align:top">\n) +
    "<span style=\"color:#{other}\">" + pretty_string + "</span>\n</pre>"
end
