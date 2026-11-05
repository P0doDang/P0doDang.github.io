# frozen_string_literal: true

source "https://rubygems.org"

gem "jekyll", "~> 4.3"

# 카테고리/태그 페이지를 자동으로 만들어 주는 플러그인
gem "jekyll-archives", "~> 2.2"

# Ruby 3 이상에서 로컬 미리보기(`jekyll serve`)에 필요해요.
gem "webrick", "~> 1.8"

gem "html-proofer", "~> 5.0", group: :test

platforms :windows, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.2.0", :platforms => [:windows]
