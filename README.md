The PaaS contract tools library contains utilities for generating tables from API document schemas and HTML for JSON
object representations for PaaS contract pages on google sites.

Usage:

1. Bundle gems

2. Generate data definition table from schema.

    a. Load your api_document into a ruby object in an irb console:

        require 'yaml'
        api_doc = YAML.load_file('path/to/api_doc.yml')

    b. Parse out the desired schema, e.g.

        my_schema = api_doc['schemas']['MySchema']

    c. Load the schema to HTML utility:

        load 'lib/schema_to_html.rb'

    d. Output the schema to the console,

        puts $s2h.call(my_schema)

       Optionally, generate the table with specified column widths:

        puts $s2h.call(my_schema, 200, 200)

    e. Paste the formatted table into the pertinent google sites page in the HTML window.

3. Generate JSON representations from JSON strings.

    a. In an irb console, define your JSON string or load it from a file, etc.:

        my_json_string = "{ \"some\": \"json\"}"

    b. Load the JSON to HTML utility:

        load 'lib/json_to_html.rb'

    c. Output the string to the console:

        puts $j2h.call(my_json_string)

       Optionally, specify custom colors (values shown are defaults):

        puts $j2h.call(my_json_string, {bracket: '#009900', delimiter: '#339933', other: '#CC0000', text: '#3366CC'})

    d. Paste the formatted HTML representation into the pertinent google sites page in the HTML window.
