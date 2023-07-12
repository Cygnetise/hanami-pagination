module Hanami
  module Pagination
    class Pager
      attr_reader :pager

      def initialize(pager)
        @pager = pager
      end

      def next_page
        num = current_page + 1
        num if total_pages >= num
      end

      def prev_page
        @prev_page ||= pager.prev_page
      end

      def total
        @total ||= pager.total
      end

      def total_pages
        @total_pages ||= (total / pager.per_page.to_f).ceil
      end

      def current_page
        @current_page ||= pager.current_page
      end

      def current_page?(page)
        current_page == page
      end

      def pages_range(delta: 3)
        first = current_page - delta
        first = first > 0 ? first : 1

        last = current_page + delta
        last = last < total_pages ? last : total_pages

        (first..last).to_a
      end

      def all_pages
        (1..total_pages).to_a
      end

      def first_page?
        current_page == 1
      end

      def last_page?
        total < 1 || current_page == total_pages
      end
    end
  end
end
