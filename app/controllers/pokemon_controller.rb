require 'csv'

class PokemonController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :load_csv

  def index
    result = @pokemons
    if(query_parameters[:rows_per_page].to_i > 0 && query_parameters[:page].to_i > 0 )
      result = result
        .drop(query_parameters[:rows_per_page].to_i * (query_parameters[:page].to_i - 1))
        .take(query_parameters[:rows_per_page].to_i)
    end

    render json: result
  end

  def create
    new_pokemon = map_pokemon_hash_to_pokemon(params)
    @pokemons.push(new_pokemon)
    result = @pokemons.map{|pokemon| map_pokemon_to_hash(pokemon)} 
    write_csv(result)

    render json: {created: true}
  end

  def show
    render json: @pokemons.filter{|pokemon| pokemon.id == params[:id].to_i}[0]
  end

  def edit
    index = @pokemons.index{|pokemon| pokemon.id == params[:id] }
    @pokemons[index] = map_pokemon_hash_to_pokemon(params)
    result = @pokemons.map{|pokemon| map_pokemon_to_hash(pokemon)} 
    write_csv(result)

    render json: { updated: true } 
  end

  def destroy
    result = @pokemons.delete_if{|pokemon| pokemon.id == params[:id].to_i}.map{|pokemon| map_pokemon_to_hash(pokemon)} 
    write_csv(result)

    render json: { destroyed: true }
  end

  private

  def query_parameters
    params.permit(:rows_per_page, :page).to_h
  end

  def load_csv
    csv_text = File.read(Rails.root.join("lib", "csvs", "pokemon.csv"))
    csv = CSV.parse(csv_text, :headers => true, :encoding => "ISO-8859-1")
    @pokemons = []
    csv.each.with_index do |row, index|
      @pokemons.push(map_hash_to_pokemon(index, row))
    end
  end

  def write_csv(result)
    CSV.open(Rails.root.join("lib", "csvs", "pokemon.csv"), "w", :write_headers => true, headers: result[0].keys) {
      |csv| result.each{
        |pokemon| csv << pokemon
      }
    }
  end

  def map_hash_to_pokemon(index, pokemon_hash)
    pokemon = Pokemon.new
    pokemon.id = index.to_i + 1
    pokemon.pokemon_number = pokemon_hash["#"].to_i
    pokemon.name = pokemon_hash["Name"]
    pokemon.type_1 = pokemon_hash["Type 1"]
    pokemon.type_2 = pokemon_hash["Type 2"]
    pokemon.total = pokemon_hash["Total"].to_i
    pokemon.health_points = pokemon_hash["HP"].to_i
    pokemon.attack = pokemon_hash["Attack"].to_i
    pokemon.defense = pokemon_hash["Defense"].to_i
    pokemon.special_attack = pokemon_hash["Sp. Atk"].to_i
    pokemon.special_defence = pokemon_hash["Sp. Def"].to_i
    pokemon.speed = pokemon_hash["Speed"].to_i
    pokemon.generation = pokemon_hash["Generation"].to_i
    pokemon.legendary = pokemon_hash["Lengendary"].to_s.downcase == "true"

    pokemon
  end

  def map_pokemon_to_hash(pokemon)
    pokemon_hash = Hash.new
    pokemon_hash["#"] = pokemon.pokemon_number.to_s
    pokemon_hash["Name"] = pokemon.name
    pokemon_hash["Type 1"] = pokemon.type_1
    pokemon_hash["Type 2"] = pokemon.type_2
    pokemon_hash["Total"] = pokemon.total.to_s
    pokemon_hash["HP"] = pokemon.health_points.to_s
    pokemon_hash["Attack"] = pokemon.attack.to_s
    pokemon_hash["Defense"] = pokemon.defense.to_s
    pokemon_hash["Sp. Atk"] = pokemon.special_attack.to_s
    pokemon_hash["Sp. Def"] = pokemon.special_defence.to_s
    pokemon_hash["Speed"] = pokemon.speed.to_s
    pokemon_hash["Generation"] = pokemon.generation.to_s
    pokemon_hash["Lengendary"] = pokemon.legendary.to_s.capitalize()

    pokemon_hash
  end

  def map_pokemon_hash_to_pokemon(pokemon_hash)
    pokemon = Pokemon.new
    pokemon.id = pokemon_hash[:id]
    pokemon.pokemon_number = pokemon_hash[:pokemon_number]
    pokemon.name = pokemon_hash[:name]
    pokemon.type_1 = pokemon_hash[:type_1]
    pokemon.type_2 = pokemon_hash[:type_2]
    pokemon.total = pokemon_hash[:total]
    pokemon.health_points = pokemon_hash[:health_points]
    pokemon.attack = pokemon_hash[:attack]
    pokemon.defense = pokemon_hash[:defense]
    pokemon.special_attack = pokemon_hash[:special_attack]
    pokemon.special_defence = pokemon_hash[:special_defence]
    pokemon.speed = pokemon_hash[:speed]
    pokemon.generation = pokemon_hash[:generation]
    pokemon.legendary = pokemon_hash[:legendary]

    pokemon
  end

end
