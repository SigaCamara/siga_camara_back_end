Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do    
    namespace :v1 do    
      get 'parlamentares', to: 'parlamentares#lista'
      get 'parlamentares/:id', to: 'parlamentares#lista'
      get 'materias/tipos', to: 'materias#lista_tipos'
      get 'materias/consulta_materia', to: 'materias#consulta_materia'
      get 'materias/consulta_materia_ementa', to: 'materias#consulta_materia_ementa'
      get 'materias/consulta_materia_resumo', to: 'materias#consulta_materia_resumo'
      get 'materias/consulta_materia_indexacao', to: 'materias#consulta_materia_indexacao'
      get 'materias/consulta_materia_bairro', to: 'materias#consulta_materia_bairro'
      get 'materias/:id', to: 'materias#materia'
      get 'bairros', to: 'bairros#lista'
      get 'bairros/consulta', to: 'bairros#consulta'
      get 'bairros/bairros_lat_long', to: 'bairros#bairros_lat_long'
      get 'bairros/lat_lng', to: 'bairros#lista_lat_lng'
    end    
  end  
end
