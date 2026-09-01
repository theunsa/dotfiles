# Renders the editor's unsaved markdown through the real MarkdownRenderer, so
# the preview can't drift from what the client will actually see.
class Admin::PreviewsController < Admin::BaseController
  def create
    @html = MarkdownRenderer.new(params[:body_markdown]).to_html

    render layout: false
  end
end
