require_relative 'spec_helper'
require 'nokogiri'
require 'active_support/core_ext'

module ChildExtractors
  include ExtractionSugar::Macros
  include ExtractionSugar::NameConversions

  define_extractor :child_content do |child_name|
    subject.at_xpath(child_name).try(:content)
  end

  define_extractor :child_time do |child_name|
    str = child_content(child_name)
    Time.parse(str) if str
  end

  define_extractor :child_inner_html do |child_name|
    subject.at_xpath(child_name).try :inner_html
  end

  define_extractor :child_link_href do |rel|
    subject.at_xpath("link[@rel='#{rel}']").try :[], 'href'
  end

  define_extractor :child_attribute do |child_name, attribute_name|
    subject.at_xpath(child_name).try :[], attribute_name
  end
end

class GoogleSitesEntry < Struct.new :subject
    include ChildExtractors
    apply_conversion CAMELIZE

    child_content {
        id
        title
        page_name
        revision
    }
    child_time {
        updated
        edited
    }
    child_inner_html { content }
    child_link_href {
        alternate
        edit
        parent "http://schemas.google.com/sites/2008#parent"
    }
    child_attribute { feed_link(:href) }
end

describe ChildExtractors do
  let(:source_xml) {%{
    <entry>
      <id>https://sites.google.com/feeds/content/domainName/siteName/1265948545471894517</id>
      <updated>2009-08-03T19:35:32.488Z</updated>
      <edited xmlns:app="http://www.w3.org/2007/app">2009-08-03T19:35:32.488Z</edited>
      <title>files</title>
      <content type="xhtml">
        <div xmlns="http://www.w3.org/1999/xhtml">Page html content here</div>
      </content>
      <link rel="http://schemas.google.com/sites/2008#parent" type="application/atom+xml"
            href="https://sites.google.com/feeds/content/domainName/siteName/6492205817"/>
      <link rel="alternate" type="text"
          href="https://sites.google.com/domainName/siteName/files"/>
      <link rel="edit" type="application/atom+xml"
          href="https://sites.google.com/feeds/content/domainName/siteName/12671894517"/>
      <feedLink href="http://sites.google.com/feeds/content/domainName/siteName?parent=12671894517"/>
      <pageName>files</pageName>
      <revision>1</revision>
    </entry>
  }}

  let(:node) { Nokogiri::XML.parse(source_xml).root }

  let(:entry) { GoogleSitesEntry.new(node) }

  context 'child_content' do
    it 'processes simple names' do
      entry.id.should == 'https://sites.google.com/feeds/content/domainName/siteName/1265948545471894517'
      entry.title.should == 'files'
      entry.revision.should == '1'
      entry.content.should =~ %r{<div xmlns="http://www.w3.org/1999/xhtml">Page html content here</div>}
      entry.alternate.should == "https://sites.google.com/domainName/siteName/files"
      entry.edit.should == "https://sites.google.com/feeds/content/domainName/siteName/12671894517"
    end

    it 'processes extractors refering other extractors' do
      entry.updated.should == Time.parse('2009-08-03T19:35:32.488Z')
      entry.edited.should == Time.parse('2009-08-03T19:35:32.488Z')
    end

    it 'processes converted names' do
      entry.page_name.should == 'files'
    end

    it 'processes extractors with additional arguments' do
      entry.feed_link.should == "http://sites.google.com/feeds/content/domainName/siteName?parent=12671894517"
    end

    it 'allows to redefine an explicit pattern' do
      entry.parent.should == "https://sites.google.com/feeds/content/domainName/siteName/6492205817"
    end

    it 'defines let for custom extractions'
  end
end
