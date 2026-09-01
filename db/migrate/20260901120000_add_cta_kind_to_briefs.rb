class AddCtaKindToBriefs < ActiveRecord::Migration[8.1]
  # The CTA is no longer WhatsApp-only: an account can send clients to WhatsApp,
  # email, a phone call, or nothing at all. The two WhatsApp columns become the
  # generic value/prefill pair, and cta_kind says how to read them.
  def up
    rename_column :briefs, :whatsapp_number, :cta_value
    rename_column :briefs, :whatsapp_text, :cta_text
    add_column :briefs, :cta_kind, :string, null: false, default: "none"
    execute "UPDATE briefs SET cta_kind = 'whatsapp' WHERE cta_value IS NOT NULL AND cta_value != ''"
  end

  def down
    remove_column :briefs, :cta_kind
    rename_column :briefs, :cta_value, :whatsapp_number
    rename_column :briefs, :cta_text, :whatsapp_text
  end
end
