require 'sivel2_gen/version'

Msip.setup do |config|
  config.ruta_anexos = ENV.fetch('SIP_RUTA_ANEXOS', 
                                 "#{Rails.root}/archivos/anexos/")
  config.ruta_volcados = ENV.fetch('SIP_RUTA_VOLCADOS',
                                   "#{Rails.root}/archivos/bd/")
  # En heroku los anexos son super-temporales
  if ENV["HEROKU_POSTGRESQL_MAUVE_URL"]
    config.ruta_anexos = "#{Rails.root}/tmp/"
  end
  config.titulo = "BDHN #{Sivel2Gen::VERSION}"
  config.paisomision = 340

  config.descripcion = "Sistema de información de casos de violencia socio política en Honduras"
  config.codigofuente = "https://gitlab.com/pasosdeJesus/si_bdhn"
  config.urlcontribuyentes = "https://gitlab.com/pasosdeJesus/si_bdhn/-/graphs/main"
  config.urlcreditos = "https://gitlab.com/pasosdeJesus/si_bdhn/-/blob/main/CREDITOS.md"
  config.agradecimientoDios = "<p>
  Agradecemos a Dios por su palabra y por permitir este desarrollo, el cual 
  le dedicamos.
  </p>
<blockquote>
Pero recibiréis poder, cuando haya venido sobre vosotros el Espíritu Santo, 
y me seréis testigos en Jerusalén, en toda Judea, en Samaria, 
y hasta lo último de la tierra.
<br>
Hechos 1:8
<blockquote>".html_safe

end
