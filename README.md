Extraction Sugar
===

This is a mini-framework fro defining DSLs to extract data in a convinient form from structures like `Nokogiri::XML::Node`.


    <entry>
      <id>https://sites.google.com/feeds/content/domainName/siteName/1265948545471894517</id>
      <updated>2009-08-03T19:35:32.488Z</updated>
      <edited xmlns:app="http://www.w3.org/2007/app">2009-08-03T19:35:32.488Z</edited>
      <title>files</title>
      <content type="xhtml">
        <div xmlns="http://www.w3.org/1999/xhtml">Page html content here</div>
      </content>
      <link rel="alternate" type="text"
          href="https://sites.google.com/domainName/siteName/files"/>
      <link rel="self" type="application/atom+xml"
          href="https://sites.google.com/feeds/content/domainName/siteName/12671894517"/>
      <link rel="edit" type="application/atom+xml"
          href="https://sites.google.com/feeds/content/domainName/siteName/12671894517"/>
      <feedLink href="httpn://sites.google.com/feeds/content/domainName/siteName?parent=12671894517"/>
      <pageName>files</pageName>
      <revision>1</revision>
    </entry>




You may have following DSL to parse the above XML:

    class GoogleSitesEntry
        include ChildExtractors
        
        child_content {
            id
            title
            page_name
            feed_link
        }   
        child_time {
            updated
            edited
        }
        child_inner_html { content }
        child_link_href {
            alternate
            self
            edit
        }
    end
    
    module ChildExtractors
        
    end

Dillinger is a cloud-enabled HTML5 Markdown editor.

  - Type some Markdown text in the left window
  - See the HTML in the right
  - Magic

Markdown is a lightweight markup language based on the formatting conventions that people naturally use in email.  As [John Gruber] writes on the [Markdown site] [1]:

> The overriding design goal for Markdown's
> formatting syntax is to make it as readable 
> as possible. The idea is that a
> Markdown-formatted document should be
> publishable as-is, as plain text, without
> looking like it's been marked up with tags
> or formatting instructions.

This text your see here is *actually* written in Markdown! To get a feel for Markdown's syntax, type some text into the left window and watch the results in the right.  

Version
-

2.0

Tech
-----------

Dillinger uses a number of open source projects to work properly:

* [Ace Editor] - awesome web-based text editor
* [Showdown] - a port of Markdown to JavaScript
* [Twitter Bootstrap] - great UI boilerplate for modern web apps
* [node.js] - evented I/O for the backend
* [Express] - fast node.js network app framework [@tjholowaychuk]
* [keymaster.js] - awesome keyboard handler lib by [@thomasfuchs]
* [jQuery] - duh 

Installation
--------------

```sh
git clone [git-repo-url] dillinger
cd dillinger
npm i -d
mkdir -p public/files/{md,html,pdf}
node app
```


License
-

MIT

*Free Software, Fuck Yeah!*

  [john gruber]: http://daringfireball.net/
  [@thomasfuchs]: http://twitter.com/thomasfuchs
  [1]: http://daringfireball.net/projects/markdown/
  [showdown]: https://github.com/coreyti/showdown
  [ace editor]: http://ace.ajax.org
  [node.js]: http://nodejs.org
  [Twitter Bootstrap]: http://twitter.github.com/bootstrap/
  [keymaster.js]: https://github.com/madrobby/keymaster
  [jQuery]: http://jquery.com  
  [@tjholowaychuk]: http://twitter.com/tjholowaychuk
  [express]: http://expressjs.com
  

    xtraction Sugar
===

This is intended to be a mini-framework for defining DSLs to conviniently extract data from structures like `Nokogiri::XML::Node`.

    <entry>
      <id>https://sites.google.com/feeds/content/domainName/siteName/1265948545471894517</id>
      <updated>2009-08-03T19:35:32.488Z</updated>
      <edited xmlns:app="http://www.w3.org/2007/app">2009-08-03T19:35:32.488Z</edited>
      <title>files</title>
      <content type="xhtml">
        <div xmlns="http://www.w3.org/1999/xhtml">Page html content here</div>
      </content>
      <link rel="alternate" type="text"
          href="https://sites.google.com/domainName/siteName/files"/>
      <link rel="self" type="application/atom+xml"
          href="https://sites.google.com/feeds/content/domainName/siteName/12671894517"/>
      <link rel="edit" type="application/atom+xml"
          href="https://sites.google.com/feeds/content/domainName/siteName/12671894517"/>
      <feedLink href="httpn://sites.google.com/feeds/content/domainName/siteName?parent=12671894517"/>
      <pageName>files</pageName>
      <revision>1</revision>
    </entry>

You may have following DSL to parse the above XML:

    class GoogleSitesEntry
        include ChildExtractors
        apply_convention CamelCase

        child_content {
            id
            title
            page_name
            feed_link
        }
        child_time {
            updated
            edited
        }
        child_inner_html { content }
        child_link_href {
            alternate
            self
            edit
        }
        child_attribute { feed_link(:href) }
    end

    module ChildExtractors
      include BaseExtractor

      define_extractor :child_content do |source_node, child_name|
        source_node.at_xpath(child_name).try(:content)
      end

      define_extractor :child_time do |source_node, child_name|
        str = child_content(source_node, child_name)
        Time.parse(str) if str
      end

      ...
    end

