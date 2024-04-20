require "pathname"

module Standard
  class ResolvesYamlOption
    def call(argv, search_path, option_name, default_files)
      search_argv(argv, option_name) || find_prioritized_default(default_files, search_path)
    end

    private

    def search_argv(argv, option_name)
      return unless (config_file = argv_value_for(argv, option_name))

      resolved_config = Pathname.new(config_file)
      if resolved_config.exist?
        resolved_config.expand_path
      else
        raise "Configuration file \"#{resolved_config.expand_path}\" not found."
      end
    end

    def argv_value_for(argv, option_name)
      return unless (index = argv.index(option_name))
      argv[index + 1]
    end

    def find_prioritized_default(default_files, search_path)
      default_files
        .lazy
        .filter_map { |default_file| FileFinder.new.call(default_file, search_path) }
        .first
    end
  end
end
