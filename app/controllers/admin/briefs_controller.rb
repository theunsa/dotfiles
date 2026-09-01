class Admin::BriefsController < Admin::BaseController
  before_action :set_brief, only: %i[show edit update destroy]

  def index
    @briefs = briefs.order(created_at: :desc)
    # Two grouped queries instead of two per row, each held to this account.
    ids = @briefs.select(:id)
    @visit_counts = Visit.where(brief_id: ids).group(:brief_id).count
    @last_viewed = Visit.where(brief_id: ids).group(:brief_id).maximum(:viewed_at)
  end

  def show
    @visits = @brief.visits.order(viewed_at: :desc).limit(50)
  end

  def new
    @brief = briefs.new
    @brief.documents.build(title: "Proposal")
  end

  def edit
  end

  def create
    @brief = briefs.new(brief_params)
    if @brief.save
      redirect_to admin_brief_path(@brief), notice: "Brief created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @brief.passcode_digest = nil if params[:brief][:remove_passcode] == "1"
    if @brief.update(brief_params)
      redirect_to admin_brief_path(@brief), notice: "Brief updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @brief.destroy!
    redirect_to admin_root_path, notice: "Brief deleted."
  end

  private

  # Another account's slug 404s here, the same as one that does not exist.
  def set_brief
    @brief = briefs.find_by!(slug: params[:id])
  end

  def brief_params
    params.require(:brief).permit(
      :client_name, :whatsapp_number, :whatsapp_text, :published, :passcode,
      documents_attributes: %i[id title body_markdown]
    )
  end
end
