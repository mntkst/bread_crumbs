module BreadCrumbs
    module BreadcrumbsHelper
        def render_breadcrumbs(categories_with_keys = nil, params = {}, options = {})
            list = BreadCrumbs::List.instance
  
            # カテゴリが指定されていない場合は空文字列を返す
            return ''.html_safe if categories_with_keys.nil? || categories_with_keys.empty?
  
            breadcrumbs_html = []
            breadcrumbs_data = nil
  
            # 各カテゴリごとのパンくずリストと構造化データを生成
            categories_with_keys.each do |category, key|
                breadcrumbs = list.generate_breadcrumbs(category, key, params)

                # HTML用パンくずリスト
                breadcrumbs_html << render_breadcrumbs_for_category(breadcrumbs, options[:class] || 'breadcrumbs', options[:separator] || ' 》 ')

                # 構造化データ用パンくずリスト(ld+jsonには1セットしか推奨されないため最初の1セットだけを表示)
                breadcrumbs_data = generate_ld_json_breadcrumbs(breadcrumbs) if breadcrumbs_data.nil?
            end               
            # 全体を囲む要素でラップして返す
            render_breadcrumbs_wrapper(breadcrumbs_html, breadcrumbs_data, options)
        end        
        private
  
        def render_breadcrumbs_wrapper(breadcrumbs_html, breadcrumbs_data, options)
            content_tag(:div, class: options[:wrapper_class] || 'breadcrumbs-wrapper') do
                breadcrumbs_html.join("\n").html_safe +
                render_ld_json(breadcrumbs_data)
            end
        end        
        def render_breadcrumbs_for_category(breadcrumbs, nav_class, separator)
            content_tag(:nav, class: nav_class) do
                breadcrumbs.map do |crumb|
                    link_to(crumb[:title], crumb[:url], class: 'breadcrumb-link')
                end.join(separator).html_safe
            end
        end

        def generate_ld_json_breadcrumbs(breadcrumbs)
            list = BreadCrumbs::List.instance

            {
                "@context": "https://schema.org",
                "@type": "BreadcrumbList",
                "itemListElement": breadcrumbs.each_with_index.map do |crumb, index|
                    {
                    "@type": "ListItem",
                    "position": index + 1,
                    "name": crumb[:title],
                    "item": to_absolute_url(crumb[:url])
                    }
                end
            }
        end        
        def to_absolute_url(relative_url)
            URI.join(request.base_url, relative_url).to_s
        end        
        def render_ld_json(ld_json_data)
            content_tag(:script, type: "application/ld+json") do
                ld_json_data.to_json.html_safe
            end
        end   
    end
end
  