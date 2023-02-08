# frozen_string_literal: true

require 'coderay'

class CustomRender < Redcarpet::Render::HTML
  def block_code(code, language)
    language ||= 'text'
    CodeRay.scan(code, language).div
  end

  def hrule
    '</div><br><div class="ibox-content" style="min-height: px">'
  end
end
