module Temple
  module Filters
    # Remove ruby comments from dynamic and code
    #
    # @api public
    class CommentRemover < Filter
      def on_dynamic(code)
        [:dynamic, remove_comment(code)]
      end

      def on_code(code)
        [:code, remove_comment(code)]
      end

      def remove_comment(code)
        if code =~ /\A\s*#/
          ''
        else
          code
        end
      end
    end
  end
end
