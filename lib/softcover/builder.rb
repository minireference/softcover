module Softcover
  class Builder
    include Softcover::Utils

    attr_accessor :manifest, :built_files

    def initialize
      @manifest = Softcover::BookManifest.new(verify_paths: true,
                                              source: source)
      @built_files = []
      ensure_style_file_locations
      write_polytexnic_commands_file
      write_language_customization_file
    end

    def build!(options={})
      setup(options)
      build(options)
      verify
      self
    end

    def clean!; end

    private
      def setup; end
      def verify; end

      # Ensures the style files are in the right location.
      # This is for backwards compatibility.
      def ensure_style_file_locations
        styles_dir = Softcover::Directories::STYLES
        mkdir styles_dir
        files = Dir.glob('*.sty')
        FileUtils.mv(files, styles_dir)
      end

      # Writes out the PolyTeXnic commands from polytexnic.
      def write_polytexnic_commands_file
        Polytexnic.write_polytexnic_style_file(styles_dir)
      end

      def write_language_customization_file
        filename = File.join(styles_dir, 'language_customization.sty')
        contents = listing_customization
        File.write(filename, contents)
      end

      def styles_dir
        File.join(Dir.pwd, Softcover::Directories::STYLES)
      end


      def listing_customization
        listing = language_labels["listing"].downcase
        box     = language_labels["aside"]
        <<-EOS
% Aside box label
\\renewcommand{\\boxlabel}{#{box}}

% Codelisting captions
\\usepackage[hypcap=false]{caption}
\\DeclareCaptionFormat{#{listing}}{\\hspace{-0.2em}\\colorbox[gray]{.85}{\\hspace{0.1em}\\parbox{0.997\\textwidth}{#1#2#3}}\\vspace{-1.3\\baselineskip}}
\\captionsetup[#{listing}]{format=#{listing},labelfont=bf,skip=16pt,font={rm,normalsize}}
\\DeclareCaptionType{#{listing}}
\\newcommand{\\codecaption}[1]{\\captionof{#{listing}}{#1}}
        EOS
      end

  end
end
