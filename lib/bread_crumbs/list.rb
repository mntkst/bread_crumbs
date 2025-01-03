require 'singleton'
module BreadCrumbs
    class List
        include Singleton

        attr_reader :trees

        def initialize
            @trees = {}
            load_data
        end

        # 各カテゴリのデータをロード
        def load_data
            file_path = Rails.root.join('config', 'breadcrumbs.json')

            # ファイルの存在を確認
            unless File.exist?(file_path)
                raise StandardError, "Breadcrumbs configuration file not found at #{file_path}"
            end            

            data = JSON.parse(File.read(file_path))

            # データ構造の整合性を確認
            raise StandardError, "Invalid breadcrumbs data structure" unless data.is_a?(Hash)            

            # JSONデータをRubyのシンボルキーに変換
            @trees = data.transform_keys(&:to_sym).transform_values do |category_data|
                raise StandardError, "Invalid category data structure" unless category_data.is_a?(Hash)
                category_data.transform_keys(&:to_s)
            end
        end

        # 複数カテゴリのパンくずリストを生成
        def generate_multiple_breadcrumbs(categories_with_keys, params = {})
            categories_with_keys.map do |category, key|
                generate_breadcrumbs(category, key, params)
            end.flatten
        end        

        # 特定のカテゴリとページを起点にしたパンくずリストを生成
        def generate_breadcrumbs(category, key, params = {})
            raise ArgumentError, "Category #{category} not found in breadcrumb trees" unless @trees[category]
            raise ArgumentError, "Key #{key} not found in category #{category}" unless @trees[category][key]        

            breadcrumbs = []
            current = @trees[category][key]

            while current
                title = resolve_dynamic_title(current['title'], params)
                url = resolve_dynamic_url(current['url'], params)
                breadcrumbs.unshift({ title: title, url: url })
                current = @trees[category][current['parent']]
            end

            breadcrumbs
        end

        def category_name(category)
            raise ArgumentError, "Category #{category} not found in breadcrumb trees" unless @trees[category]
            @trees[category]["name"] || "パンくずリスト"
        end        

        # 動的URLを解決
        def resolve_dynamic_url(url, params)
            # URLテンプレートのプレースホルダーを置換
            resolved_url = url.gsub(/:([0-9a-zA-Z_]+)/) do |match|
                params[$1.to_sym] || raise_invalid_placeholder_error(url, match)
            end

            resolved_url            
        end
  
        # タイトルのプレースホルダーを解決
        def resolve_dynamic_title(title, params)
            title.gsub(/:([0-9a-zA-Z_]+)/) { |match| params[$1.to_sym] || match }
        end        

        private

        # 遅延ロードで Rails の URL ヘルパーを取得
        def url_helpers
            Rails.application.routes.url_helpers
        end
        def raise_invalid_placeholder_error(url, placeholder)
            raise "Unresolved placeholder: url=>#{url}, placeholder=>#{placeholder}"
        end
    end
end