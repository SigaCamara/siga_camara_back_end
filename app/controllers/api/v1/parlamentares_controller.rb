class Api::V1::ParlamentaresController <  Api::V1::ApiController

  def lista
    url = "http://sagl-api.campinas.sp.leg.br/parlamentares/#{params[:id]}"

    # parametro = {_parameters: [consulta.query]}        
    # retorno = RestClient.post(url, parametro.to_json)
    retorno = RestClient.get(url)
    lista = JSON(retorno.body)['data']
    render json: lista
  end

end
