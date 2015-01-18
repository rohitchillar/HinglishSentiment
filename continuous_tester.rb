require 'awesome_print'
require 'rubyXL'
# require 'normalize_hinglish'

stemming_workbook = RubyXL::Parser.parse("stemming_rules.xlsx")
@stemming_table = stemming_workbook[0].get_table(["from_suffix" , "to_suffix"])[:table]

testing_workbook = RubyXL::Parser.parse("test_clusters.xlsx")
@testing_sheet = testing_workbook[0]

# @i = 0

def hinglish_stemmer(word)
	return word if word.nil?

	word.downcase!
	#RULE : Baseline rule : trip down all the triples and double characters to single to reduce ambiguity.
	#Except o and e
	word.gsub!(/([^oe\W])(\1)+/ , '\1')
	word.gsub!(/([oe])(\1)+/ , '\1\1')
	################################
	hash = {}
	@stemming_table.each{|x| hash[x["from_suffix"]] = x["to_suffix"]  }
	from_to_hash = {} ; froms = [] ; applied_rules_hash = {}
	hash.keys.each{|from| froms += from.split(",");  from.split(",").each{|e| from_to_hash[e.strip] = hash[from.strip]}  ; }
	froms = froms.sort_by(&:size).reverse
	# ap froms

	for from in froms
		to = from_to_hash[from.strip]
		# ap "HEY: #{ not word.gsub(/#{from.strip}$/).to_a.empty?}       #{to.strip == '?'}" if from == "e" and word == "apne"
		
		boolX = (not word.gsub(/#{from.strip}$/).to_a.empty?)
		boolY = (not to.strip == "?")  rescue	true
		if boolX and boolY
			applied_rules_hash["#{from.strip}"] = "#{to}"  
			word = word.gsub(/#{from.strip}$/ ,  to.strip.gsub(/_/ , "") ) 
		end
	end

	word.gsub!(/([^oe\W])(\1)+/ , '\1')
	word.gsub!(/([oe])(\1)+/ , '\1\1')

	return word , applied_rules_hash
end


def check_row(row)
	return nil if !( (not @testing_sheet[row][0].nil? ) rescue false )
	word_wise_applied_rules = {}
	uniques = (0..99).map{|i| @testing_sheet[row][i].value rescue nil }.map{|element|  ( stemmed_word , word_wise_applied_rules[element] = hinglish_stemmer(element)  ) if not element.nil?  ;   stemmed_word  }.compact.uniq
	return uniques.size == 1 , word_wise_applied_rules
end

def print_cluster( row)

	for i in 0..100
		break if ( @testing_sheet[row].nil? or @testing_sheet[row][i].nil?  )
		print "#{@testing_sheet[row][i].value} " if not @testing_sheet[row][i].value.empty?
	end
	puts
	for i in 0..100
		break if ( @testing_sheet[row].nil? or @testing_sheet[row][i].nil?  )
		print "#{hinglish_stemmer(@testing_sheet[row][i].value)[0]} " if not @testing_sheet[row][i].value.empty?
	end
	puts 
end

def test
	for i in 0..100
		valid , applied_rules = check_row(i)
		if valid == false
			ap "Test is failing\n-------------------" 
			ap "Failing Cluster in row #{i}"
			ap "Cluster is #{i}:"
			print_cluster( i )
			ap applied_rules
			return false
		end
	end
	puts "Test passed"
	return true
end


loop do
	sleep(1)
	break if not test
end