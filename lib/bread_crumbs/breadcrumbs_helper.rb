module BreadCrumbs
    module BreadcrumbsHelper
        def render_breadcrumbs(categories_with_keys = nil, params = {}, options = {})
            list = BreadCrumbs::List.instance
  
            # カテゴリが指定されていない場合は空文字列を返す
            return ''.html_safe if categories_with_keys.nil? || categories_with_keys.empty?
  
            breadcrumbs_html = []
  
            # 各カテゴリごとのパンくずリストと構造化データを生成
            categories_with_keys.each do |category, key|
                breadcrumbs = list.generate_breadcrumbs(category, key, params)

                # HTML用パンくずリスト
                breadcrumbs_html << render_breadcrumbs_for_category(breadcrumbs, options[:class] || 'breadcrumbs', options[:separator] || ' 》 ')
            end               
            # 全体を囲む要素でラップして返す
            render_breadcrumbs_wrapper(breadcrumbs_html, options)
        end        
        private
  
        def render_breadcrumbs_wrapper(breadcrumbs_html, options)
            content_tag(:div, class: options[:wrapper_class] || 'breadcrumbs-wrapper') do
                breadcrumbs_html.join("\n").html_safe
            end

        end        
        def render_breadcrumbs_for_category(breadcrumbs, nav_class, separator)
            content_tag(:nav, class: nav_class) do
                breadcrumbs.map do |crumb|
                    link_to(crumb[:title], crumb[:url], class: 'breadcrumb-link')
                end.join(separator).html_safe
            end
        end
    end
end
  