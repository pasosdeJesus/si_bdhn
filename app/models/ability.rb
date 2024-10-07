class Ability  < Sivel2Gen::Ability


  GRUPO_DESAPARICION_CASOS = 25


  def tablasbasicas
    r = (Msip::Ability::BASICAS_PROPIAS - 
         [['Msip', 'oficina']]
        ) + Sivel2Gen::Ability::BASICAS_PROPIAS - [
          ['Sivel2Gen', 'actividadoficio'],
          ['Sivel2Gen', 'escolaridad'],
          ['Sivel2Gen', 'estadocivil'],
          ['Sivel2Gen', 'maternidad']
        ]
    return r
  end

  # Establece autorizaciones con CanCanCan
  def initialize(usuario = nil)
    initialize_sivel2_gen(usuario)
    can :contar, Sivel2Gen::Caso
    if usuario && usuario.rol then
      can [:read, :update], Mr519Gen::Encuestausuario
      case usuario.rol
      when Ability::ROLADMIN
        can :manage, Mr519Gen::Encuestausuario
      end
    end
  end

end

