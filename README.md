Extraction Sugar
===

This is a mini-framework fro defining DSLs to extract data in a convinient form from structures like `Nokogiri::XML::Node`.


Consider you have the following XML:

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

