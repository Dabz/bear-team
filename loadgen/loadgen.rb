require 'mongo'
require 'json'
require 'awesome_print'
require 'faker'
require 'as-duration'


#####################################
# Script to generate random beers for SA/CE MongoDB Hackathon Nov '16
# Badly implmented by Jim Blackhurt - jim@mongodb.com


Client = Mongo::Client.new([ 'localhost' ])

@DB = Client.use(:Beer)

Mongo::Logger.logger.level = ::Logger::WARN


@docs = Array.new


def makeFlatDocs(numDocs)
	@docs.clear
	for i in 1..numDocs
		doc = 
		{
			"name" => Faker::Beer.name,
			# todo add Brewery
			"brewery" => "The " + Faker::Hipster.word + " " + Faker::Hacker.adjective + " beer company",
			"style" => Faker::Beer.style,
			"hop" => Faker::Beer.hop,
			"yeast" => Faker::Beer.yeast,
			"malts" => Faker::Beer.malts,
			"ibu" => Faker::Beer.ibu,
			"alcohol" => Faker::Beer.alcohol,
			"blg" => Faker::Beer.blg,
			"firstBrewDate" => Faker::Time.between(3650.days.ago, Date.today, :day),
			# todo make price more realistic
			"price" => Faker::Commerce.price,
		}
		@docs << doc 		
		#ap doc
	end
end


def makeKVDocs(numDocs)
	@docs.clear
	for i in 1..numDocs
	
		name_h = {"k" => "name", "v" => Faker::Beer.name }
		brewery_h = {"k" => "brewery", "v" => "The " + Faker::Hipster.word + " " + Faker::Hacker.adjective + " beer company" }
		style_h = {"k" => "style", "v" => Faker::Beer.style }
		hop_h = {"k" => "hop", "v" => Faker::Beer.hop }
		yeast_h = {"k" => "yeast", "v" => Faker::Beer.yeast }
		malts_h = {"k" => "malts", "v" => Faker::Beer.malts }
		ibu_h = {"k" => "ibu", "v" => Faker::Beer.ibu}
		alcohol_h = {"k" => "alcohol", "v" =>Faker::Beer.alcohol}
		blg_h = {"k" => "blg", "v" =>Faker::Beer.blg}
		firstBrewDate_h = {"k" => "firstBrewDate", "v" => Faker::Time.between(3650.days.ago, Date.today, :day)}
		price_h = {"k" => "price", "v" => Faker::Commerce.price}

		doc = 
		{
			"type" => "craft_beer",
			"attr" => [name_h, brewery_h, style_h, hop_h, yeast_h, malts_h, ibu_h, alcohol_h, blg_h, firstBrewDate_h, price_h]
		}

		@docs << doc 		
		#ap doc.to_json
	end
end



def insertDocs(schema,coll,numInserts,numDocs)

	if schema.eql? "flat" 
		for i in 1..numInserts
			makeFlatDocs(numDocs)
			result = @DB[schema+"_"+coll].insert_many(@docs)
			puts i

		end
	end

	if schema.eql? "kv" 
		for i in 1..numInserts
			makeKVDocs(numDocs)
			result = @DB[schema+"_"+coll].insert_many(@docs)
			puts i

		end
	end

end

insertDocs("flat","beer",10,1000)
insertDocs("kv","beer",10,1000)

