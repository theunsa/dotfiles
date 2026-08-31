# Renders the editor's unsaved markdown through the real MarkdownRenderer, so
# the preview can't drift from what the client will actually see.
class Admin::PreviewsController < ApplicationController
  def create
    @html = MarkdownRenderer
      .new(params[:body_markdown], context: { preview: true })
      .to_html(view_context)

    render layout: false
  end
end
