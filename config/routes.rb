Rails.application.routes.draw do
  scope 'api/v1' do
    get     'pokemon'     , to: 'pokemon#index'
    get     'pokemon/:id' , to: 'pokemon#show'
    delete  'pokemon/:id' , to: 'pokemon#destroy'
    put     'pokemon' , to: 'pokemon#edit'
    post    'pokemon'     , to: 'pokemon#create'

  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
