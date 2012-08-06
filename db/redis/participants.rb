def unique_names
  names = []
  
  first_names = ["Lindsey", "Dodie", "Tommie", "Aletha", "Matilda", "Robby", "Forest", "Sherrie", "Elroy", "Darlene", "Blossom", "Preston", "Ivan", "Denisha", "Antonietta", "Lenora", "Fatimah", "Alvaro", "Madeleine", "Johnsie", "Jacki"]
  last_names = ["Austino", "Egnor", "Mclauglin", "Vettel", "Osornio", "Kloke", "Neall", "Licon", "Bergren", "Guialdo", "Heu", "Lilla", "Fogt", "Ellinghuysen", "Banner", "Gammage", "Fleniken", "Byerley", "Mccandless", "Hatchet", "Segal", "Bagnall", "Mangum", "Marinella", "Hunke", "Klis", "Skonczewski", "Aiava", "Masson", "Hochhauser", "Pfost", "Cripps", "Surrell", "Carstens", "Moeder", "Feller", "Turri", "Plummer", "Liuzza", "Macaskill", "Pirie", "Haase", "Gummersheimer", "Caden", "Balich", "Franssen", "Barbur", "Bonker", "Millar", "Armijo", "Canales", "Kucera", "Ahlstrom", "Marcoux", "Dagel", "Vandonsel", "Lagrasse", "Bolten", "Smyer", "Spiker", "Detz", "Munar", "Oieda", "Westin", "Levenson", "Ramagos", "Lipson", "Crankshaw", "Polton", "Seibt", "Genrich", "Shempert", "Bonillas", "Stout", "Caselli", "Jaji", "Kudo", "Feauto", "Hetland", "Hsieh", "Iwasko", "Jayme", "Lebby", "Dircks", "Hainley", "Gielstra", "Dozois", "Suss", "Matern", "Mcloud", "Fassio", "Blumstein", "Qin", "Gindi", "Petrizzo", "Beath", "Tonneson", "Fraga", "Tamura", "Cappellano", "Galella"]

  (0..1999).each do |i|
    first = first_names.shift
    last = last_names.shift
    names << [first,last]
    first_names.push(first)
    last_names.push(last)
  end
  names
end

def date_builder(i)
  Date.civil(enrollment_years[i.modulo(5)], (1..12).to_a[i.modulo(12)], 1)
end

def enrollment_years
  [2008,2009,2010,2011,2012]
end

def create_person(id,person)
  $redis.sadd 'person_ids', id
  $redis.hset "person:#{id}", 'first_name', person[0]
  $redis.hset "person:#{id}", 'last_name', person[1]
end

def enrollment_id(person_id,enrollment_milliseconds)
  Zlib.crc32("#{person_id}:#{enrollment_milliseconds}") % (2 ** 30 - 1)
end

def enroll_person(grantee_id,subgrantee_id,person_id,enrollment_date)
  enrollment_milliseconds = enrollment_date.to_milliseconds
  enrollment_id = enrollment_id(person_id,enrollment_milliseconds)

  $redis.sadd 'enrollment_ids', enrollment_id
  #$redis.sadd "subgrantee:#{subgrantee_id}:enrollment_ids", enrollment_id

  $redis.hset "enrollment:#{enrollment_id}", 'person_id', person_id
  $redis.hset "enrollment:#{enrollment_id}", 'date', enrollment_milliseconds
  $redis.hset "enrollment:#{enrollment_id}", 'grantee_id', grantee_id
  $redis.hset "enrollment:#{enrollment_id}", 'subgrantee_id', subgrantee_id

  #$redis.rpush "enrollment_dates_for_person:#{person_id}", enrollment_milliseconds
  #$redis.rpush "enrollment_ids_for_person:#{person_id}", enrollment_id
  $redis.zadd "enrollments_for_subgrantee_by_date:#{subgrantee_id}", enrollment_milliseconds, enrollment_id
  enrollment_id
end

def exit_person(grantee_id,subgrantee_id,person_id,enrollment_id,exit_date)
  exit_milliseconds = exit_date.to_milliseconds

  $redis.sadd 'exit_ids', enrollment_id

  $redis.hset "exit:#{enrollment_id}", 'person_id', person_id
  $redis.hset "exit:#{enrollment_id}", 'date', exit_milliseconds
  $redis.hset "exit:#{enrollment_id}", 'grantee_id', grantee_id
  $redis.hset "exit:#{enrollment_id}", 'subgrantee_id', subgrantee_id
  $redis.zadd "exits_for_subgrantee_by_date:#{subgrantee_id}", exit_milliseconds, enrollment_id
end

def place_person(grantee_id, subgrantee_id,person_id,enrollment_id,exit_date)
  exit_milliseconds = exit_date.to_milliseconds

  $redis.sadd 'placement_ids', enrollment_id

  $redis.hset "placement:#{enrollment_id}", 'person_id', person_id
  $redis.hset "placement:#{enrollment_id}", 'date', exit_milliseconds
  $redis.hset "placement:#{enrollment_id}", 'grantee_id', grantee_id
  $redis.hset "placement:#{enrollment_id}", 'subgrantee_id', subgrantee_id
  $redis.zadd "placements_for_subgrantee_by_date:#{subgrantee_id}", exit_milliseconds, enrollment_id
end


# subgrantee_id = 1

# Create one enrollment for all participants
unique_names.each_with_index do |person,i|
  create_person(i,person)
  grantee_id = 1
  # subgrantee_id = ((subgrantee_id == 1) ? 2 : 1)
  subgrantee_id = (i < 1000) ? 1 : 2

  enrollment_date = date_builder(i)
  enrollment_id = enroll_person(grantee_id,subgrantee_id,i,enrollment_date)

  #50% enrollments end with exit
  if i.modulo(2) == 0

    exit_date = enrollment_date + 30
    
    #25% of exits are for placement
    if i.modulo(8) == 0
      place_person(grantee_id,subgrantee_id,i,enrollment_id,exit_date)
    else
      exit_person(grantee_id,subgrantee_id,i,enrollment_id,exit_date)
    end
    
    #50% of exits re-enroll 90 days after exit
    if i.modulo(4) == 0
      second_enrollment_date = exit_date + 90
      enroll_person(grantee_id,subgrantee_id,i,second_enrollment_date)
    end
  end
end