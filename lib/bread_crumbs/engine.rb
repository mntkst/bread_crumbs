module BreadCrumbs
    class Engine < ::Rails::Engine
        isolate_namespace BreadCrumbs

        initializer 'bread_crumbs.load_helpers' do
            ActiveSupport.on_load(:action_controller_base) do
                helper BreadCrumbs::BreadcrumbsHelper
            end
        end
    end
end