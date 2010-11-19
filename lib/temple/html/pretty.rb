module Temple
  module HTML
    class Pretty < Fast
      set_default_options :indent => '  ',
                          :pretty => true,
                          :indent_tags => %w(base dd div dl doctype dt fieldset form head h1 h2 h3
                                             h4 h5 h6 hr html img input li link meta ol p script
                                             style table tbody td tfoot th thead title tr ul).freeze,
                          :pre_tags => %w(pre textarea).freeze

      def initialize(opts = {})
        super
        @last = nil
        @stack = []
      end

      def on_static(content)
        @last = nil
        [:static, options[:pretty] ? content.gsub("\n", indent) : content]
      end

      def on_dynamic(content)
        @last = nil
        [:dynamic, options[:pretty] ? %{(#{content}).to_s.gsub("\n", #{indent.inspect})} : content]
      end

      def on_html_doctype(type)
        @last = 'doctype'
        super
      end

      def on_html_comment(content)
        return super if !options[:pretty]
        [:multi, [:static, indent], super]
      end

      def on_html_tag(name, attrs, closed, content)
        return super if !options[:pretty]

        closed ||= options[:autoclose].include?(name)
        raise "Closed tag #{name} has content" if closed && !empty_exp?(content)

        result = [:multi, [:static, "#{tag_indent(name)}<#{name}"], compile!(attrs)]
        result << [:static, ' /'] if closed && xhtml?
        result << [:static, '>']

        @stack << name
        @last = name
        result << compile!(content)
        @stack.pop

        result << [:static, "#{tag_indent(name)}</#{name}>"] if !closed
        @last = name
        result
      end

      protected

      # Return indentation if not in pre tag
      def indent
        preformatted? ? '' : ("\n" + ((options[:indent] || '') * @stack.size))
      end

      # Are we in a preformatted text area
      def preformatted?
        options[:pre_tags].any? {|tag| @stack.include?(tag) }
      end

      # Return indentation before tag
      def tag_indent(name)
        @last && (options[:indent_tags].include?(@last) || options[:indent_tags].include?(name)) ? indent : ''
      end
    end
  end
end