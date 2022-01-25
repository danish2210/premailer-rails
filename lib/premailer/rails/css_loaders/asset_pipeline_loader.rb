class Premailer
  module Rails
    module CSSLoaders
      module AssetPipelineLoader
        extend self

        def load(url)
          return unless asset_pipeline_present?

          file = file_name(url)

          find_source file
        rescue Errno::ENOENT, TypeError => _e
        end

        def file_name(url)
          prefix = [
            ::Rails.configuration.relative_url_root,
            ::Rails.configuration.assets.prefix,
            '/'
          ].join
          URI(url).path
                  .sub(/\A#{prefix}/, '')
                  .sub(/-(\h{32}|\h{64})\.css\z/, '.css')
        end

        def asset_pipeline_present?
          defined?(::Rails) &&
            ::Rails.respond_to?(:application) &&
            ::Rails.application &&
            ::Rails.application.respond_to?(:assets_manifest) &&
            ::Rails.application.assets_manifest
        end

        def find_source(file_name)
          if ::Rails.configuration.assets.compile
            # Dynamic compilation
            ::Rails.application.assets.find_asset(file_name)
          else
            # Pre-compiled
            ::Rails.application.assets_manifest.assets[file_name]
          end
        end
      end
    end
  end
end
