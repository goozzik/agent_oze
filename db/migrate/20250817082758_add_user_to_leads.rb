class AddUserToLeads < ActiveRecord::Migration[8.0]
  def change
    add_reference :leads, :user, null: true, foreign_key: true
    
    # Assign all existing leads to the first user if any exists
    if User.exists?
      Lead.update_all(user_id: User.first.id)
    end
  end
end
