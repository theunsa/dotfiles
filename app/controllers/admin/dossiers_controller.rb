class Admin::DossiersController < Admin::BaseController
  before_action :set_dossier, only: %i[show edit update destroy]

  def index
    @dossiers = dossiers.order(created_at: :desc)
    # Three grouped queries instead of three per row, each held to this account.
    ids = @dossiers.select(:id)
    @visit_counts = Visit.where(dossier_id: ids).group(:dossier_id).count
    @last_viewed = Visit.where(dossier_id: ids).group(:dossier_id).maximum(:viewed_at)
    @accepted_ids = Acceptance.where(dossier_id: ids).distinct.pluck(:dossier_id).to_set
  end

  def show
    @visits = @dossier.visits.order(viewed_at: :desc).limit(50)
  end

  def new
    @dossier = dossiers.new
    @dossier.documents.build(title: "Proposal")
  end

  def edit
  end

  def create
    @dossier = dossiers.new(dossier_params)
    if @dossier.save
      redirect_to admin_dossier_path(@dossier), notice: "Dossier created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @dossier.passcode_digest = nil if params[:dossier][:remove_passcode] == "1"
    if @dossier.update(dossier_params)
      redirect_to admin_dossier_path(@dossier), notice: "Dossier updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dossier.destroy!
    redirect_to admin_root_path, notice: "Dossier deleted."
  end

  private

  # Another account's slug 404s here, the same as one that does not exist.
  def set_dossier
    @dossier = dossiers.find_by!(slug: params[:id])
  end

  def dossier_params
    params.require(:dossier).permit(
      :client_name, :whatsapp_number, :whatsapp_text, :published, :passcode,
      documents_attributes: %i[id title body_markdown]
    )
  end
end
