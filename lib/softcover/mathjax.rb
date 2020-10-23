module Softcover
  module Mathjax

    # Returns the MathJax configuration.
    def self.config(options = {})
      chapter_number = if options[:chapter_number]
                         if (options[:chapter_number].zero? ||
                             options[:chapter_number] == 99999 ||
                             Softcover::Utils.article?)
                             false
                           else
                             # Call .inspect.inspect to escape the chapter
                             # number code for interpolation.
                             options[:chapter_number].inspect.inspect
                           end
                         elsif options[:chapter_number].nil?
                           '#{chapter_number}'
                       else  # chapter_number is false, i.e., it's a single page
                         false
                       end
      fn = if chapter_number
             "formatNumber: function (n) { return #{chapter_number} + '.' + n }"
           else
             ""
           end

      config = <<-EOS
      MathJax.Hub.Config({
        extensions: ["tex2jax.js", "MathMenu.js", "MathZoom.js", "fast-preview.js"],
        "HTML-CSS": {
          availableFonts: ["TeX"],
          preferredFont: "TeX",
          webFont: "TeX",
          imageFont: null
        },
        SVG: {
          font: "TeX"
        },
        TeX: {
          extensions: ["AMSmath.js", "AMSsymbols.js", "color.js", "cancel.js", "mhchem.js"],
          equationNumbers: {
            autoNumber: "AMS",
            #{fn}
          },
          Macros: {
            PolyTeX:    "Poly{\\\\TeX}",
            PolyTeXnic: "Poly{\\\\TeX}nic",
            emph: ["{#1}", 1],
            // FROM MATH & PHYS BOOK
            eqdef: "\\\\stackrel{\\\\scriptscriptstyle\\\\text{def}}{=}",
            cotan: "\\\\textrm{cotan}",
            sech: "\\\\textrm{sech}",
            button: ["\\\\boxed{\\\\,#1\\\\phantom{\\\\small l}\\\\!}", 1],
            scalebox: ["{#2}", 2],
            octagon: "\\\\textrm{octagon}",
            ds: "\\\\displaystyle",
            efrac: ["\\\\frac{#1}{#2}", 2],
            qedsymbol: "\\\\square",
            // FROM LA BOOK
            mathbbm: ["\\\\mathbb{#1}", 1],
            sfT: "{\\\\mathsf{T}}",
            colvec: ["\\\\left[\\\\begin{array}{c} #1 \\\\end{array}\\\\right]", 1],
            Tr: "\\\\textrm{Tr}",
            tensor: ["{\\\\vphantom{#2}#1\\\\!{#2}#3}", 3, ""],
            lightning: "\\\\leadsto",
            // PROB
            psub: ["#1_{#2\\\\!}", 2, "p"],
            musub: ["#1_{#2\\\\!}", 2, "\\\\mu"],
            myepsdice: ["\\\\boxed{#1}", 1],
            // QUANTUM
            bra: ["\\\\langle #1|", 1],
            ket: ["|#1 \\\\rangle", 1],
            braket: ["\\\\langle #1 \\\\rangle", 1],
            ketbra: ["\\\\ket{#1}\\\\bra{#2}", 2],
            #{custom_macros}
          }
        },
        showProcessingMessages: false,
        messageStyle: "none",
        imageFont: null
      });
      EOS
      config
    end

    # Rerturns a version of the MathJax configuration escaped for the server.
    # There's an extra interpolation somewhere between here and the server,
    # which this method corrects for.
    def self.escaped_config(options={})
      self.config(options).gsub('\\', '\\\\\\\\')
    end

    MATHJAX  = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config='
    AMS_HTML = MATHJAX + 'TeX-AMS_HTML'
    AMS_SVG  = MATHJAX + 'TeX-AMS-MML_SVG'

    # Returns the custom macros as defined in the custom style file.
    def self.custom_macros
      extract_macros(Softcover.custom_styles)
    end

    private

      # Extracts and formats the macros from the given string of style commands.
      # The output format is compatible with the macro configuration described
      # at http://docs.mathjax.org/en/latest/tex.html.
      def self.extract_macros(styles)
        # For some reason, \ensuremath doesn't work in MathJax, so remove it.
        styles.gsub!('\ensuremath', '')
        # First extract commands with no arguments.
        cmd_no_args = /^\s*\\newcommand\{\\(.*?)\}\{(.*)\}/
        cna = styles.scan(cmd_no_args).map do |name, definition|
          escaped_definition = definition.gsub('\\', '\\\\\\\\')
          %("#{name}": "#{escaped_definition}")
        end
        # Then grab the commands with arguments.
        cmd_with_args = /^\s*\\newcommand\{\\(.*?)\}\[(\d+)\]\{(.*)\}/
        cwa = styles.scan(cmd_with_args).map do |name, number, definition|
          escaped_definition = definition.gsub('\\', '\\\\\\\\')
          %("#{name}": ["#{escaped_definition}", #{number}])
        end
        (cna + cwa).join(",\n")
      end
  end
end
