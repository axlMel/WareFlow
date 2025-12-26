module ApplicationHelper
  include Pagy::Frontend

  def sidebar_link_to(path, icon:, label:, icon_class: "w-6 h-6 opacity-70 group-hover:opacity-100", data: {})
    link_to path, data: data, class: "sidebar-link flex space-x-2 pl-3 w-full group hover:opacity-100 transition" do
      image_tag(icon, class: icon_class) +
        content_tag(:span, label, class: "menu-label group-hover:opacity-100")
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    icon = if column == params[:sort]
             params[:direction] == "asc" ? "▲" : "▼"
           else
             ""
           end
    link_to "#{title} #{icon}".html_safe, request.query_parameters.merge(sort: column, direction: direction)
  end
end