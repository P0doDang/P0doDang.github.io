# frozen_string_literal: true

# kramdown은 <mark>, <toc> 같은 "모르는" HTML 태그 안쪽을 마크다운으로 해석하지 않는다.
# 이 태그들을 글자 단위(span) 태그로 등록해서 안쪽에서도 **굵게**, *기울임*, `코드`, [링크](주소)가 동작하게 한다.
require "kramdown"

module Kramdown
  module Parser
    class Html
      module Constants
        %w[mark toc toc1 toc2 toc3].each do |tag|
          HTML_SPAN_ELEMENTS << tag unless HTML_SPAN_ELEMENTS.include?(tag)
          HTML_CONTENT_MODEL[tag] = :span
        end
      end
    end
  end
end