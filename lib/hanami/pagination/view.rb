require 'hanami/helpers'

module Hanami
  module Pagination
    module View
      include Hanami::Helpers

      def self.[](*prefixes)
        Base.new(prefixes)
      end

      class Base < Module
        def initialize(prefixes = [nil])
          @prefixes = prefixes
        end

        def included
          prefixes = @prefixes

          prefixes.each do |prefix|
            prefixer = proc do |string|
              [prefix, string].compact.join('_').to_sym
            end

            define_method(prefixer.call(:next_page_url)) do
              send(prefixer.call(:page_url), send(prefixer.call(:pager), :next_page))
            end

            define_method(prefixer.call(:prev_page_url)) do
              send(prefixer.call(:page_url), send(prefixer.call(:pager), :prev_page))
            end

            define_method(prefixer.call(:page_url)) do |page|
              "#{params.env['REQUEST_PATH']}?#{prefixer.call(:page)}=#{page}"
            end

            define_method(prefixer.call(:previous_page_path)) do |page|
              routes.path(page, **params, prefixer(:page) => send(prefixer.call(:pager), :prev_page))
            end

            define_method(prefixer.call(:next_page_path)) do |page|
              routes.path(page, **params, prefixer(:page) => send(prefixer.call(:pager), :next_page))
            end

            define_method(prefixer.call(:n_page_path)) do |page, n|
              routes.path(page, **params, prefixer(:page) => n)
            end

            define_method(prefixer.call(:paginate)) do |page|
              html.nav(class: 'pagination') do
                pager = send(prefixer.call(:pager))
                content = []

                content << send(prefixer.call(:first_page_tag), page) unless pager.first_page?
                content << send(prefixer.call(:ellipsis_tag)) if pager.current_page > 3
                content << send(prefixer.call(:previous_page_tag), page) if pager.current_page > 2
                content << send(prefixer.call(:current_page_tag))
                content << send(prefixer.call(:next_page_tag), page) if (pager.total_pages - pager.current_page) > 1
                content << send(prefixer.call(:ellipsis_tag)) if (pager.total_pages - pager.current_page) > 3
                content << send(prefixer.call(:last_page_tag), page) unless pager.last_page?

                raw(content.map(&:to_s).join)
              end
            end

            define_method(prefixer.call(:first_page_tag)) do |page|
              html.a(href: send(prefixer.call(:n_page_path), page, 1), class: 'pagination-first-page') do
                '1'
              end
            end

            define_method(prefixer.call(:previous_page_tag)) do |page|
              html.a(href: send(prefixer.call(:previous_page_path), page), class: 'pagination-previous-page') do
                pager = send(prefixer.call(:pager))
                pager.prev_page
              end
            end

            define_method(prefixer.call(:current_page_tag)) do
              html.span(class: 'pagination-current-page') do
                pager = send(prefixer.call(:pager))
                pager.current_page
              end
            end

            define_method(prefixer.call(:last_page_tag)) do |page|
              total_pages = pager.total_pages
              html.a(href: send(prefixer.call(:n_page_path), page, total_pages), class: 'pagination-last-page') do
                total_pages
              end
            end

            define_method(prefixer.call(:next_page_tag)) do |page|
              pager = send(prefixer.call(:pager))
              html.a(href: send(prefixer.call(:next_page_path), page), class: 'pagination-next-page') do
                pager.next_page
              end
            end
          end
        end

        def ellipsis_tag
          html.span(class: 'pagination-ellipsis') do
            '...'
          end
        end
      end
    end
  end
end
