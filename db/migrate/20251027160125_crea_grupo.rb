class CreaGrupo < ActiveRecord::Migration[7.2]
  def up
    Msip::Grupo.create({
      id: 101,
      nombre: "Solo ve sus casos",
      observaciones: "No puede ver ni editar casos de otros usuarios",
      fechacreacion: "2025-10-27",
      created_at: "2025-10-27",
      updated_at: "2025-10-27"
    })
  end
  def down
    g = Msip::Grupo.find(101)
    g.delete
  end
end
