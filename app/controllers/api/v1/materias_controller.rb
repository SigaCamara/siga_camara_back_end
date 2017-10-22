class Api::V1::MateriasController < Api::V1::ApiController
  using Accentless

  def lista_tipos
    lista = tipos_materias
    render json: lista
  end

  def consulta_materia
    lista = consulta_completa
    render json: lista
  end

  def consulta_materia_resumo
    lista = consulta_completa
    resumo = []

    lista.each do |materia|
      resumo.push({id: materia['id'], ementa: materia['ementa'], indexacao: materia['indexacao']})
    end

    render json: resumo
  end

  def consulta_materia_ementa
    lista_seleta = []
    lista = consulta_completa
    lista.each do |materia|
      unless materia['ementa'].upcase.index(params[:ementa].upcase).nil?
        lista_seleta.push(materia)
      end
    end
    render json: lista_seleta
  end

  def consulta_materia_indexacao
    lista_seleta = []
    lista = consulta_completa
    lista.each do |materia|
      unless materia['indexacao'].upcase.index(params[:indexacao].upcase).nil?
        lista_seleta.push(materia)
      end
    end
    render json: lista_seleta
  end

  def consulta_materia_bairro
    bairro = params[:bairro].to_s.accentless.downcase
    bairro_alias = Api::V1::BairrosController.alias_bairro(bairro).downcase

    materias = consulta_completa

    retorno = []

    materias.each do |materia|
      ementa = materia['ementa'].downcase.sub('.', '')
      indexacao = materia['indexacao'].downcase.sub('.', '')
      if ementa =~ /#{bairro}/ || ementa =~ /#{bairro_alias}/ ||
         indexacao =~ /#{bairro}/ || indexacao =~ /#{bairro_alias}/
        retorno.push(materia)
      end
    end

    render json: retorno
  end

  def materia
    url = "http://sagl-api.campinas.sp.leg.br/materias/#{params[:id]}"
    retorno = RestClient.get(url)
    m = JSON(retorno.body)['data']
    incluir_parlamentar_materia(m)
    render json: m
  end

  private    

    def incluir_parlamentar_materia(materia)
      autores_parlamentares = []

      materia['autores_parlamentares'].each do |id|
        url = "http://sagl-api.campinas.sp.leg.br/parlamentares/#{id}"      
        parlamentares = JSON RestClient.get(url)
        autores_parlamentares.push(parlamentares['data'])
      end

      materia['autores_parlamentares'] = autores_parlamentares;
    end  

    def consulta_completa
      consulta = []

      anos = []      

      if params[:ano].nil?
        ano_atual = Date.today.year
        anos.push("ano=#{ano_atual}&")
        # anos.push("ano=#{ano_atual-1}&")
      else
        anos.push("ano=#{params[:ano]}&")
      end

      tipos = []

      if params[:tipo_materia].nil?
        tipos_materias.each do |tipo|
          tipos.push("tipo_materia_id=#{tipo['id']}")
        end
      else
        tipos.push("tipo_materia_id=#{params[:tipo_materia]}")
      end

      if params[:bairro].nil?
        bairro = params[:bairro].to_s.accentless.downcase
        bairro_alias = Api::V1::BairrosController.alias_bairro(bairro).downcase
      end

      url = "http://sagl-api.campinas.sp.leg.br/materias?"      

      anos.each do |ano|
        tipos.each do |tipo|
          if params[:parlamentar].nil?
            parlamentar = ""
          else
            parlamentar = "&parlamentar_id=#{params[:parlamentar]}"
          end
          url_full = url + ano + tipo + parlamentar
          pp url_full
          retorno = RestClient.get(url_full)
          lista = JSON(retorno.body)['data']
          lista.each do |materia|
            continuar = false
            unless params[:bairro].nil?
              ementa = materia['ementa'].downcase.sub('.', '')
              indexacao = materia['indexacao'].downcase.sub('.', '')
              if ementa =~ /#{bairro}/ || ementa =~ /#{bairro_alias}/ ||
                indexacao =~ /#{bairro}/ || indexacao =~ /#{bairro_alias}/
                continuar = true
              end            
            else
              continuar = true              
            end

            if continuar
              unless params[:assunto].nil?
                if materia['ementa'].accentless.upcase =~ /#{params[:assunto].accentless.upcase}/ ||
                   materia['indexacao'].accentless.upcase =~ /#{params[:assunto].accentless.upcase}/
                  continuar = true
                else
                  continuar = false
                end
              else
                continuar = true              
              end
            end             
            
            consulta.push(materia) if continuar
          end
        end
      end

      unless params[:lat_lng].nil?
        if params[:lat_lng]
          bairros_lat_lng = Api::V1::BairrosController.carregar_bairros_lat_long
          consulta_mapa = []
          
          bairros_lat_lng.each do |bairro_lat_lng|   
            consulta.each do |c|              

              bairro_alias = Api::V1::BairrosController.alias_bairro(bairro_lat_lng['bairro']).accentless
              bairro_down = bairro_lat_lng['bairro'].accentless.downcase
              bairro_alias.downcase!
        
              if c['ementa'].accentless.downcase =~ /#{bairro_down}/ || 
                 c['indexacao'].accentless.downcase =~ /#{bairro_alias}/
                consulta_mapa.push(bairro_lat_lng.merge({id_materia: c['id']}))
              end

            end
          end

          consulta = consulta_mapa

        end
      end

      consulta
    end

    def tipos_materias
      url = "http://sagl-api.campinas.sp.leg.br/tipos-materia"      
      # parametro = {_parameters: [consulta.query]}        
      # retorno = RestClient.post(url, parametro.to_json)
      retorno = RestClient.get(url)
      JSON(retorno.body)['data']
    end 
end
