class AddNegotiationStatusToLeads < ActiveRecord::Migration[8.0]
  def up
    # First update existing enum values to new ones (shift won, lost, followup)
    execute <<-SQL
      UPDATE leads SET status = 7 WHERE status = 6; -- followup: 6 -> 7
      UPDATE leads SET status = 6 WHERE status = 5; -- lost: 5 -> 6
      UPDATE leads SET status = 5 WHERE status = 4; -- won: 4 -> 5
    SQL
    # negotiation: 4 will be available for new records
  end

  def down
    # Remove any negotiation status records first
    execute "DELETE FROM leads WHERE status = 4"
    # Then shift back
    execute <<-SQL
      UPDATE leads SET status = 4 WHERE status = 5; -- won: 5 -> 4
      UPDATE leads SET status = 5 WHERE status = 6; -- lost: 6 -> 5
      UPDATE leads SET status = 6 WHERE status = 7; -- followup: 7 -> 6
    SQL
  end
end
