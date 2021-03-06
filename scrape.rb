require 'json'
require 'csv'
require 'parallel'
require 'open-uri'
require 'settingslogic'

class Settings < Settingslogic
  source "scrape.yml"
end

set = Settings.new
weapons_url = "http://battlelog.battlefield.com/bf4/warsawWeaponsPopulateStats/#{set['personaID']}/1/unlocks/"
accessories_url = "http://battlelog.battlefield.com/bf4/warsawWeaponAccessoriesPopulateStats/#{set['personaID']}/1/"
output = "#{set['outputName']}.csv"

weaponStatsJSON = JSON.parse(open(weapons_url).read)
weapons = Array.new


Parallel.each(weaponStatsJSON['data']['mainWeaponStats'], :in_threads => 20, :in_processes => 2) do |wepStats|
  guid = wepStats['guid']

  accessoriesJSON = JSON.parse(open(accessories_url + "#{guid}/").read)

  completed = 0
  totalAccessories = accessoriesJSON['data']['statsItemUnlocks'].length
  totalUnlockableAccessories = 0
  totUnlockableAccessUnlocked = 0
  if totalAccessories > 0  
    accessoriesJSON['data']['statsItemUnlocks'].each do |accessory|
      # This includes battlepack unlocked accessories
      if accessory['unlockedBy']['completed']
        if accessory['unlockedBy']['valueNeeded'] != nil 
          totUnlockableAccessUnlocked += 1
        end
        completed += 1
      end
      if accessory['unlockedBy']['valueNeeded'] != nil
        totalUnlockableAccessories += 1 
      end
    end
  end

  # For our columns, these map the JSON names to the column names. Text means it's going to copy
  #   from wepStats directly.
  cols = { 
    'Name'                         => 'slug',
    'Kills'                        => 'kills',
    'Category'                     => 'category',
    'Unlocked Accessories' => totUnlockableAccessUnlocked,
    'Total Unlockable Accessories' => totalUnlockableAccessories,
    "Other Accessories"            => totalAccessories-totalUnlockableAccessories,
    "Other Accessories Obtained"   => completed-totUnlockableAccessUnlocked,
    'Accessories Obtained'         => completed,
    'Total Accessories'            => totalAccessories,
  }

  # Hack for capital names:
  wepStats[cols['Name']].swapcase!

  # Map our values over.
  cols.each do |i, val|
    if val.is_a? String
      cols[i] = wepStats[val]
    end
  end

  weapons << cols
end


CSV.open(output, 'w') do |csv|
  csv << weapons.first.keys

  weapons.each do |hash|
    csv << hash.values
  end
end
