class HomologaMunicipiosSistImp < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL

    DROP VIEW IF EXISTS hommunhn;
    CREATE OR REPLACE VIEW hommunhn AS (
      SELECT DISTINCT m.id AS mid1, d.id AS did1,
        m.nombre AS m1, d.nombre AS d1, 
        m2.nombre AS m2, d2.nombre AS d2, 
        d2.id AS did2, m2.id AS mid2 
        FROM sip_municipio AS m
        JOIN sip_departamento AS d ON d.id=m.id_departamento 
        JOIN sip_departamento AS d2 ON d.id=d2.id+99940 
        JOIN sip_municipio AS m2 ON m2.id_departamento=d2.id 
          AND (unaccent(m2.nombre)=unaccent(m.nombre) OR 
            (m.id=100008 and m2.id=1549))
        WHERE m.id >= 100001 
          AND m.id <= 100302 
          ORDER BY 1
      ); 

    UPDATE sip_persona
      SET id_departamento=did2,
      id_municipio=mid2
      FROM hommunhn AS h WHERE sip_persona.id_municipio=h.mid1;

    UPDATE sip_persona
      SET id_departamento=id_departamento-99940
      WHERE id_departamento>=100001 AND id_departamento<=100018;

    UPDATE sip_ubicacionpre
      SET departamento_id=did2,
      municipio_id=mid2
      FROM hommunhn AS h WHERE sip_ubicacionpre.municipio_id=h.mid1;

    UPDATE sip_ubicacionpre
      SET departamento_id=departamento_id-99940
      WHERE departamento_id>=100001 AND departamento_id<=100018;

    UPDATE sip_ubicacion 
      SET id_departamento=did2,
      id_municipio=mid2
      FROM hommunhn AS h WHERE sip_ubicacion.id_municipio=h.mid1;

    UPDATE sip_ubicacion 
      SET id_departamento=id_departamento-99940
      WHERE id_departamento>=100001 AND id_departamento<=100018;

    DROP VIEW IF EXISTS hommunhn;

    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration    
  end
end
