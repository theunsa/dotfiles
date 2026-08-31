class Admin::DossiersController < ApplicationController
  before_action :set_dossier, only: %i[show edit update destroy]

  def index
    @dossiers = Dossier.order(created_at: :desc)
  end

  def show
    @visits = @dossier.visits.order(viewed_at: :desc).limit(50)
  end

  def new
    @dossier = Dossier.new
    @dossier.documents.build(title: "Proposal")
  end

  def edit
  end

  def create
    @dossier = Dossier.new(dossier_params)
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

  def set_dossier
    @dossier = Dossier.find_by!(slug: params[:id])
  end

  def dossier_params
    params.require(:dossier).permit(
      :client_name, :whatsapp_number, :whatsapp_text, :published, :passcode,
      documents_attributes: %i[id title body_markdown]
    )
  end
end
