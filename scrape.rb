require 'json'
require 'csv'
require 'parallel'
require 'open-uri'


cfg = IO.readlines('scrape.cfg')
personaID = cfg[0].split('=')[1].chomp
outputName = cfg[1].split('=')[1].chomp

weapons_url = "http://battlelog.battlefield.com/bf4/warsawWeaponsPopulateStats/#{personaID}/1/unlocks/"
accessories_url = "http://battlelog.battlefield.com/bf4/warsawWeaponAccessoriesPopulateStats/#{personaID}/1/"
output = "#{outputName}.csv"

weaponStatsJSON = JSON.parse(open(weapons_url).read())
weapons = Hash.new


Parallel.each(weaponStatsJSON['data']['mainWeaponStats'], :in_threads => 20, :in_processes => 2) do |weaponStats|
    name = weaponStats['slug']
    guid = weaponStats['guid']
    kills = weaponStats['kills']
    category = weaponStats['category']

    accessoriesJSON = JSON.parse(open(accessories_url + "#{guid}/").read())

    completed = 0
    totalAccessories = accessoriesJSON['data']['statsItemUnlocks'].length
    if totalAccessories > 0  
        accessoriesJSON['data']['statsItemUnlocks'].each do |accessory|
            if accessory['unlockedBy']['completed']
                completed += 1
            end
        end

        weapons[name] = {'kills' => kills, 'unlocked accessories' => completed, 'total accessories' => totalAccessories, 'category' => category}
    end
end


CSV.open(output, 'w') do |csv|
    csv << ['name', 'percent complete'].concat(weapons.values[0].keys)
    
    weapons.each do |name, hash|
        percent = hash['unlocked accessories'].fdiv(hash['total accessories']).round(3)
        csv << [name, percent].concat(hash.values)
    end
end