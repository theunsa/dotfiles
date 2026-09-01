class BriefsController < ApplicationController
  include BriefScoped

  before_action :require_unlocked

  VISIT_DEDUPE_WINDOW = 30.minutes

  def show
    @document = @brief.primary_document
    response.headers["X-Robots-Tag"] = "noindex, nofollow, noarchive, noimageindex"
    record_visit
  end

  private

  # One visit per session per 30 minutes; the author's own views don't count.
  def record_visit
    return if author?

    seen = session[:seen_briefs] ||= {}
    last = seen[@brief.id.to_s]
    return if last && Time.zone.at(last) > VISIT_DEDUPE_WINDOW.ago

    Visit.record(@brief, request)
    seen[@brief.id.to_s] = Time.current.to_i
  end
end
