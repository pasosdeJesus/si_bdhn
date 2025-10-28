# frozen_string_literal: true

class Ability < Sivel2Gen::Ability
  GRUPO_SOLOVESUSCASOS = 101

  def tablasbasicas
    r = (Msip::Ability::BASICAS_PROPIAS -
         [["Msip", "oficina"]]
        ) + Sivel2Gen::Ability::BASICAS_PROPIAS - [
          ["Sivel2Gen", "actividadoficio"],
          ["Sivel2Gen", "escolaridad"],
          ["Sivel2Gen", "estadocivil"],
          ["Sivel2Gen", "maternidad"],
        ]
    r
  end

  # Establece autorizaciones con CanCanCan
  def initialize(usuario = nil)
    habilidad = self
    habilidad.can(:read, [Msip::Pais, Msip::Departamento, Msip::Municipio, Msip::Centropoblado, Msip::Ubicacionpre])

    # Hacer conteos
    habilidad.can(:cuenta, Sivel2Gen::Caso)

    # La consulta web es publica dependiendo de
    if !usuario && Rails.application.config.x.sivel2_consulta_web_publica
      habilidad.can(:read, Msip::Ubicacionpre)

      habilidad.can(
        [
          :buscar,
          :contar,
          :lista,
          :presenta_datos_mapaosm,
        ],
        Sivel2Gen::Caso,
      )

      habilidad.can([:read, :filtra_por_tviolencia], Sivel2Gen::Categoria)

      # API público
      # Mostrar un caso con casos/101
      # Mostrar un caso en XML - HTML con casos/101.xml
      # Mostrar un caso en XML para descarga casos/101.xrlat
      habilidad.can([:read, :show], Sivel2Gen::Caso)

      # Mostrar registros limitados
      habilidad.can(:index4000, Sivel2Gen::Caso)
    end

    if !usuario || usuario.fechadeshabilitacion
      return
    end

    # Los siguientes son para todo autenticado

    habilidad.can(
      [
        :buscar,
        :contar,
        :exportaCSV,
        :lista,
        :presenta_datos_mapaosm,
        :reportar,
      ],
      Sivel2Gen::Caso,
    )
    habilidad.can([:read, :update], Mr519Gen::Encuestausuario)
    habilidad.can(:read, Msip::Orgsocial)

    # Conteos
    habilidad.can(:victimizaciones, Sivel2Gen::Caso)
    habilidad.can(:filtra_por_tviolencia, Sivel2Gen::Categoria)
    habilidad.can(:genvic, Sivel2Gen::Caso)
    habilidad.can(:personas, Sivel2Gen::Caso)

    habilidad.can(:descarga_anexo, Msip::Anexo)
    habilidad.can(:mostrar_portada, Msip::Anexo)
    habilidad.can(:abre_anexo, Msip::Anexo)
    habilidad.can(:manage, Sivel2Gen::AnexoCaso)

    habilidad.can(:contar, Msip::Ubicacion)
    habilidad.can(:mundep, Msip::Ubicacionpre)

    habilidad.can(:manage, Sivel2Gen::CasoEtiqueta)
    habilidad.can(:manage, Sivel2Gen::CasoFuenteprensa)
    habilidad.can(:manage, Sivel2Gen::CasoFotra)
    habilidad.can(:manage, Sivel2Gen::CasoPresponsable)
    habilidad.can(:manage, Sivel2Gen::CasoSolicitud)
    habilidad.can(:nuevo, Sivel2Gen::Combatiente)
    habilidad.can(:nuevo, Sivel2Gen::Presponsable)
    habilidad.can(:manage, Sivel2Gen::Victima)
    habilidad.can(:manage, Sivel2Gen::Victimacolectiva)
    habilidad.can(:guardar_y_editar, Sivel2Gen::Caso)

    if usuario && usuario.rol
      habilidad.can(:nuevo, Msip::Ubicacion)
      case usuario.rol
      when Ability::ROLANALI
        habilidad.can(:read, Heb412Gen::Doc)
        habilidad.can(:read, Heb412Gen::Plantilladoc)
        habilidad.can(:read, Heb412Gen::Plantillahcm)
        habilidad.can(:read, Heb412Gen::Plantillahcr)
        habilidad.can(:index, Sivel2Gen::Victima)

        if usuario.grupo &&
            usuario.grupo.pluck(:id).include?(GRUPO_ANALISTA_CASOS)
          habilidad.can(
            [:read, :new, :edit, :update, :create],
            Msip::Orgsocial,
          )
          habilidad.can(:create, Msip::Bitacora, usuario: { id: usuario.id })
          habilidad.can(:read, Msip::Bitacora, usuario: { id: usuario.id })
          habilidad.can(:manage, Msip::Ability.lista_modelos_persona)
          habilidad.can(:manage, Msip::Grupoper)


          habilidad.can(:manage, Sivel2Gen::Acto)
          habilidad.can(:manage, Sivel2Gen::Actocolectivo)
          if usuario.grupo.pluck(:id).include?(GRUPO_SOLOVESUSCASOS)
            habilidad.can(
              [
                :read,
                :new,
                :edit,
                :update,
                :create,
                :importa,
                :importarrelatos,
                :errores_importacion,
                :nuevo,
                :nueva,
                :destroy,
              ],
              Sivel2Gen::Caso,
              {caso_usuario: {usuario_id: usuario.id}}
            )
          else  
            habilidad.can(
              [
                :read,
                :new,
                :edit,
                :update,
                :create,
                :importa,
                :importarrelatos,
                :errores_importacion,
                :nuevo,
                :nueva,
                :destroy,
              ],
              Sivel2Gen::Caso,
            )
          end

          habilidad.cannot(:solocambiaretiquetas, Sivel2Gen::Caso)
          habilidad.can([:refresca, :validar], Sivel2Gen::Caso)

          habilidad.can(:read, Sivel2Gen::Victima)
        else
          habilidad.can(:read, Msip::Orgsocial)
          habilidad.can(:read, Msip::Bitacora, usuario: { id: usuario.id })
          habilidad.can(:read, Msip::Ability.lista_modelos_persona)
          habilidad.can(:read, Msip::Grupoper)

          habilidad.can(:read, Sivel2Gen::Acto)
          habilidad.can(:read, Sivel2Gen::Actocolectivo)
          habilidad.cannot([:new, :create], Sivel2Gen::Caso)
          habilidad.can(:read, Sivel2Gen::Victima)

          if usuario.grupo &&
              usuario.grupo.pluck(:id)
            .include?(GRUPO_OBSERVADOR_PARTE_CASOS)
          dicc_filtro = {}
          if usuario.filtrodepartamento_ids.count > 0
            dicc_filtro[:ubicacion] = {
              departamento_id: usuario.filtrodepartamento_ids,
            }
          end
          fini = if Sivel2Gen::Caso.all.minimum(:fecha)
                   Sivel2Gen::Caso.all.minimum(:fecha)
                 else
                   Date.new(1970, 0o1, 0o1)
                 end
          if usuario.observadorffechaini
            fini = usuario.observadorffechaini
          end
          ffin = Date.today
          if usuario.observadorffechafin
            ffin = usuario.observadorffechafin
          end
          dicc_filtro[:fecha] = (fini..ffin)
          habilidad.can([:show, :read], Sivel2Gen::Caso, dicc_filtro)
          else # Suponemos que es Observador de todo
            habilidad.can(
              [:read, :edit, :solocambiaretiquetas, :update],
              Sivel2Gen::Caso,
            )
          end
        end
      when Ability::ROLADMIN
        habilidad.can(:manage, Heb412Gen::Doc)
        habilidad.can(:manage, Heb412Gen::Plantilladoc)
        habilidad.can(:manage, Heb412Gen::Plantillahcm)
        habilidad.can(:manage, Heb412Gen::Plantillahcr)

        habilidad.can(:manage, Mr519Gen::Formulario)
        habilidad.can(:manage, Mr519Gen::Encuestausuario)

        habilidad.can(:manage, Msip::Orgsocial)
        habilidad.can(:manage, Msip::Bitacora)
        habilidad.can(:manage, Msip::Ability.lista_modelos_persona)
        habilidad.can(:manage, Msip::Grupoper)
        habilidad.can(:manage, Msip::Respaldo7z)
        habilidad.can(:manage, Msip::Ubicacionpre)

        habilidad.can(:manage, Sivel2Gen::Acto)
        habilidad.can(:manage, Sivel2Gen::Actocolectivo)
        habilidad.can(:manage, Sivel2Gen::Caso)
        habilidad.cannot(:solocambiaretiquetas, Sivel2Gen::Caso)
        habilidad.can(:read, Sivel2Gen::Victima)

        habilidad.can(:manage, Usuario)
        habilidad.can(:manage, :tablasbasicas)
        habilidad.tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          habilidad.can(:manage, c)
        end
      end # case
    end # if

    can(:contar, Sivel2Gen::Caso)
    if usuario && usuario.rol
      can([:read, :update], Mr519Gen::Encuestausuario)
      case usuario.rol
      when Ability::ROLADMIN
        can(:manage, Mr519Gen::Encuestausuario)
      end
    end
  end
end
