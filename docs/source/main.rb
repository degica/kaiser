# frozen_string_literal: true

def create_page(title, path, files, &block)

  sidenav_page path, "Kaiser Docs - #{title}" do
    request_css 'css/main.css'

    brand 'Kaiser Docs'

    menu do
      files.each do |x|
        next if x[:path] == ''

        nav x[:info]['title'], :file, "/#{x[:path]}/"
      end
    end

    header do
      col 12 do
        h2 'Kaiser Documentation'
        breadcrumb [title]
      end
    end

    row do
      col 12 do
        instance_eval(&block)
      end
    end
  end

end
