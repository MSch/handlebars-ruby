require 'spec_helper'
require 'handlebars'

describe Handlebars::Parser do

  it 'parses extended paths' do
    lexer = Handlebars::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{../../header}}</h1>
<div>{{./header}}
{{hans/hubert/header}}</div>
{{#ines/ingrid/items}}
a
{{/ines/ingrid/items}}
EOF

    expected = [:multi, 
        [:static, "<h1>"], 
        [:mustache, :etag, "../../header"],
        [:static, "</h1>\n<div>"],
        [:mustache, :etag, "./header"], 
        [:static, "\n"], 
        [:mustache, :etag, "hans/hubert/header"],
        [:static, "</div>\n"], 
        [:mustache, :section, "ines/ingrid/items", [:multi, 
          [:static, "a\n"]]]]
    tokens.should eq(expected)
  end
  it 'parses the mustache example' do
    lexer = Handlebars::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{header}}</h1>
{{#items}}
{{#first}}
  <li><strong>{{name}}</strong></li>
{{/first}}
{{#link}}
  <li><a href="{{url}}">{{name}}</a></li>
{{/link}}
{{/items}}

{{#empty}}
<p>The list is empty.</p>
{{/empty}}
EOF

    expected = [:multi,
      [:static, "<h1>"],
      [:mustache, :etag, "header"],
      [:static, "</h1>\n"],
      [:mustache,
        :section,
        "items",
        [:multi,
          [:mustache,
            :section,
            "first",
            [:multi,
              [:static, "<li><strong>"],
              [:mustache, :etag, "name"],
              [:static, "</strong></li>\n"]]],
          [:mustache,
            :section,
            "link",
            [:multi,
              [:static, "<li><a href=\""],
              [:mustache, :etag, "url"],
              [:static, "\">"],
              [:mustache, :etag, "name"],
              [:static, "</a></li>\n"]]]]],
      [:mustache,
        :section,
        "empty",
        [:multi, [:static, "<p>The list is empty.</p>\n"]]]]

    tokens.should eq(expected)
  end
end
