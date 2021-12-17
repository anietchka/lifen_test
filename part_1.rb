# = Test tech Lifen (Ruby)

# == Première partie : commentaire composé
#
# Le contrôleur ci-dessous souffre de problèmes de performance. Par ailleurs,
# les choix qui ont été fait pendant son écriture (dans la syntaxe, les méthodes utilisées,
# l'architecture générale, etc.) sont personnels.
#
# Que changeriez-vous dans ce contrôleur ? En plus de régler les lenteurs de l'action `index`,
# quels modifications voulez-vous apporter pour que le code vous semble plus correct, élégant,
# et conforme à votre style personnel et à vos convictions ?

# Assets belongs to parent and author
# at any given time, one parent can only have one active asset
class AssetsController < ApplicationController
  before_action :find_asset, only: [:activate, :deactivate]
  def index
    # Je pars du principe que le model Asset a un attribut full_size qui est defini dans une methode
    # par sa longueur et sa largeur, lors de la création de l'Asset
    @assets = Asset.where(active: true).where('created_at > ?', 2.days.ago)
    render json: @assets.to_json(
        :only => [:title, :full_size],
        :include => {
          :parent => {only: [:id]},
          :author => {only: [:name]}
        })
  end

  def activate
    activate_asset(@asset)
    redirect_to @asset, notice: 'Asset activé'
  end

  def deactivate
    deactivate_asset(@asset)
    redirect_to @asset, notice: 'Asset desactivé'
  end

  private

  def find_asset
    @asset = Asset.find(params[:id])
  end

  def activate_asset(asset)
    asset.update(active: true)
    asset.parent.assets.each do |other_asset|
      other_asset.update(active: false) if other_asset != asset || other_asset.active?
    end
    AssetMailer.activated(asset).deliver_now
  end

  def deactivate_asset(asset)
    asset.update(active: false)
    AssetMailer.deactivated(asset).deliver_now
  end
end
