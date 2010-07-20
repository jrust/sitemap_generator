module SitemapGenerator
  module Link
    extend self

    # Return a Hash of options suitable to pass to a SitemapGenerator::Builder::SitemapFile instance.
    def generate(path, options = {})
      if path.is_a?(SitemapGenerator::Builder::SitemapFile)
        options.reverse_merge!(:host => path.hostname, :lastmod => path.lastmod)
        path = path.sitemap_path
      end

      options.assert_valid_keys(:priority, :changefreq, :lastmod, :host, :images, :news)
      options.reverse_merge!(:priority => 0.5, :changefreq => 'weekly', :lastmod => Time.now, :host => Sitemap.default_host, :images => [], :news => {})
      {
        :path => path,
        :priority => options[:priority],
        :changefreq => options[:changefreq],
        :lastmod => options[:lastmod],
        :host => options[:host],
        :loc => URI.join(options[:host], path).to_s,
        :images => prepare_images(options[:images], options[:host]),
        :news => prepare_news(options[:news])
      }
    end

    # Return an Array of image option Hashes suitable to be parsed by SitemapGenerator::Builder::SitemapFile
    def prepare_images(images, host)
      images.delete_if { |key,value| key[:loc] == nil }
      images.each do |r|
        r.assert_valid_keys(:loc, :caption, :geo_location, :title, :license)
        r[:loc] = URI.join(host, r[:loc]).to_s
      end
      images[0..(SitemapGenerator::MAX_SITEMAP_IMAGES-1)]
    end

    # Return news option Hash suitable to be parsed by SitemapGenerator::Builder::SitemapFile
    def prepare_news(news_options)
      return {} if news_options[:publication_name] == nil || news_options[:title] == nil
      news_options.assert_valid_keys(:publication_name, :publication_language, :publication_date, :access, :genres, :title, :keywords, :stock_tickers)
      news_options.reverse_merge!(:publication_language => 'en', :publication_date => Time.now)
      news_options
    end
  end
end

