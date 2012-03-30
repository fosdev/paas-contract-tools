require 'yaml'

module Kernel
  # this is the Y-combinator, which allows anonymous recursive functions. for a simple example,
  # to define a recursive function to return the length of an array:
  #
  #  length = ycomb do |len|
  #    proc{|list| list == [] ? 0 : len.call(list[1..-1]) }
  #  end
  #
  # see https://secure.wikimedia.org/wikipedia/en/wiki/Fixed_point_combinator#Y_combinator
  # and chapter 9 of the little schemer, available as the sample chapter at http://www.ccs.neu.edu/home/matthias/BTLS/
  def ycomb
    proc{ |f| f.call(f) }.call(proc{ |f| yield proc{ |*x| f.call(f).call(*x) } })
  end
  module_function :ycomb
end

$s2h = proc do |schema, *column_widths|
  key_width, additional_width = if column_widths.any?
    column_widths
  else
    case schema['id']
    when /deploymentdescription/i
      [104]
    when /eureka.*yml/i
      [290, 124]
    else
      []
    end
  end

%Q(<table border="1" cellpadding="3" cellspacing="0" style="line-height:17px">
  <tbody>
    <tr>
      <td style="#{key_width && "width:#{key_width}px"}"><b>key</b></td>
      <td><b>description</b></td>
      <td style="#{additional_width && "width:#{additional_width}px"}"><b>additional info</b></td>
     </tr>\n) +
  ycomb do |describe|
    proc do |schema, pkeys|
      tds = []
      tds << %Q(<span style="font-family:lucida console, courier new,monospace">#{pkeys}</span>)
      htmlify = proc{|s| s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("  ", " &nbsp;").chomp("\n").gsub("\n", "<br>") }
      tds << htmlify.call(schema['description'] || '')
      tds << htmlify.call(schema.reject{|k, _| %w(description properties additionalProperties items).include?(k) }.to_yaml.sub(/\A---\s*\n/, ''))
      trs = []
      trs << " <tr>\n"+tds.map{|td| "  <td>#{td}</td>\n" }.join('')+" </tr>\n" unless pkeys.empty?
      if schema['properties']
        trs += schema['properties'].map do |property_name, property_schema|
          newkey = pkeys.empty? ? property_name : "["+property_name+"]"
          describe.call(property_schema, pkeys+newkey)
        end
      end
      if schema['additionalProperties']
        trs << describe.call(schema['additionalProperties'], pkeys+"[&lt;<i>property</i>&gt;]")
      end
      if schema['items']
        trs << describe.call(schema['items'], pkeys+"[]")
      end
      trs.join('')
    end
  end.call(schema, '') + "</tbody>\n</table>"
end
