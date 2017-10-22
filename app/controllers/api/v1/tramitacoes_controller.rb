class Api::V1::TramitacoesController < Api::V1::ApiController
  def lista
    url = "http://sagl-api.campinas.sp.leg.br/tramitacoes/#{params[:materia]}"

    retorno = RestClient.get(url)
    lista = JSON(retorno.body)['data']
    render json: lista
  end
end
