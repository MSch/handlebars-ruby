require 'spec_helper'
require 'handlebars'

describe Handlebars::Parser do

  it 'parses the handlebars inverted section syntax' do
    lexer = Handlebars::Parser.new
    tokens = lexer.compile(<<-EOF)
{{#project}}
<h1>{{name}}</h1>
<div>{{body}}</div>
{{^}}
<h1>No projects</h1>
{{/project}}
EOF
    expected = [:multi,
      [:mustache, :section, "project", nil, [:multi,
        [:static, "<h1>"],
        [:mustache, :etag, "name", nil],
        [:static, "</h1>\n<div>"],
        [:mustache, :etag, "body", nil],
        [:static, "</div>\n"]]],
      [:mustache, :inverted_section, "project", [:multi,
        [:static, "<h1>No projects</h1>\n"]]]]
    tokens.should eq(expected)
  end

  it 'parses the mustache inverted section syntax' do
    lexer = Handlebars::Parser.new
    tokens = lexer.compile(<<-EOF)
{{#project}}
<h1>{{name}}</h1>
<div>{{body}}</div>
{{/project}}
{{^project}}
<h1>No projects</h1>
{{/project}}
EOF
    expected = [:multi, 
      [:mustache, :section, "project", nil, [:multi, 
        [:static, "<h1>"], 
        [:mustache, :etag, "name", nil], 
        [:static, "</h1>\n<div>"], 
        [:mustache, :etag, "body", nil], 
        [:static, "</div>\n"]]], 
        [:mustache, :inverted_section, "project", [:multi, 
          [:static, "<h1>No projects</h1>\n"]]]]
    tokens.should eq(expected)
  end

  it 'parses helpers with context paths' do
    lexer = Handlebars::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{helper context}}</h1>
<h1>{{helper ..}}</h1>
{{#items ..}}
haha
{{haha}}
{{/items}}
EOF

    expected = [:multi,
      [:static, "<h1>"],
      [:mustache, :etag, "helper", "context"],
      [:static, "</h1>\n<h1>"],
      [:mustache, :etag, "helper", ".."],
      [:static, "</h1>\n"],
      [:mustache, :section, "items", "..", [:multi,
        [:static, "haha\n"],
        [:mustache, :etag, "haha", nil],
        [:static, "\n"]]]]
    tokens.should eq(expected)
  end

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
      [:mustache, :etag, "../../header", nil],
      [:static, "</h1>\n<div>"],
      [:mustache, :etag, "./header", nil],
      [:static, "\n"],
      [:mustache, :etag, "hans/hubert/header", nil],
      [:static, "</div>\n"],
      [:mustache, :section, "ines/ingrid/items", nil, [:multi,
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
      [:mustache, :etag, "header", nil],
      [:static, "</h1>\n"],
      [:mustache,
        :section,
        "items",
        nil,
        [:multi,
          [:mustache,
            :section,
            "first",
            nil,
            [:multi,
              [:static, "<li><strong>"],
              [:mustache, :etag, "name", nil],
              [:static, "</strong></li>\n"]]],
          [:mustache,
            :section,
            "link",
            nil,
            [:multi,
              [:static, "<li><a href=\""],
              [:mustache, :etag, "url", nil],
              [:static, "\">"],
              [:mustache, :etag, "name", nil],
              [:static, "</a></li>\n"]]]]],
      [:mustache,
        :section,
        "empty",
        nil,
        [:multi, [:static, "<p>The list is empty.</p>\n"]]]]

    tokens.should eq(expected)
  end
end
