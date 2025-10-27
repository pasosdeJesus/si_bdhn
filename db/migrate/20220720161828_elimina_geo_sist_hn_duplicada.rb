# frozen_string_literal: true

class EliminaGeoSistHnDuplicada < ActiveRecord::Migration[7.0]
  def up
    execute(<<-SQL)
      DELETE FROM sip_ubicacionpre WHERE municipio_id>=100001 AND municipio_id<=100302;
      DELETE FROM sip_ubicacionpre WHERE departamento_id>=100001 AND departamento_id<=100018;
      DELETE FROM sip_municipio WHERE id>=100001 AND id<=100302;
      DELETE FROM sip_departamento WHERE id>=100001 AND id<=100018;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
