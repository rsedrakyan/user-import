module ApplicationHelper
  def render_results_list(results)
    content_tag(:ol) do
      results.map do |result|
        status = content_tag(:span, I18n.t("users.upload.results.statuses.#{result[:status]}"))
        errors = result[:status] == :error ? render_errors_list(result[:errors]) : ''

        content_tag(:li) do
          status + errors
        end
      end.join.html_safe
    end
  end

  def render_errors_list(errors)
    content_tag(:ul) do
      errors.collect { |error| concat(content_tag(:li, error)) }
    end
  end
end
