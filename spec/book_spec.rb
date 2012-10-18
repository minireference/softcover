require 'spec_helper'

describe Polytexnic::Book do
  context "#initialize" do
    context "valid book directory" do
      before { chdir_to_book }

      its(:files) { should_not include "html/test-book.html"}
      its(:files) { should_not include "html/test-book_fragment.html"}

      its(:files) { should include "html/chapter-1_fragment.html"}
      its(:files) { should_not include "html/chapter-1.html"}

      its(:files) { should include "test-book.mobi"}
      its(:files) { should include "test-book.epub"}
      its(:files) { should include "test-book.pdf"}

      its(:slug) { should eq "test-book" }
    end

    context "valid md book directory" do
      before { chdir_to_md_book }

      its(:slug) { should eq "md-book" }
    end
  end

  context "#create" do

  end
end