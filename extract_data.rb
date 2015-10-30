require 'json'
require 'byebug'

drillings = Marshal::load(File.read("./sigpeg.dat"))
original_headers = ["Numéro du puits", "Nom du puits", "Région géologique", "Latitude (décimal)", "Longitude (décimal)", "Entreprise forage"]
target_headers = ["number", "name", "region", "latitude", "longitude", "company", "start", "end"]
headers_dates = ["Date de début", "Date de fin"]

json_data = []
json = File.open("./sigpeg_forages.json", "wb")
tab = File.open("./tous_les_forages.tab", "w")


tab.puts target_headers.join("\t")

drillings.each do |drilling|
  out = {}
  original_headers.each_with_index do |header, index|
    out[target_headers[index]] = drilling[header]
  end

  if (drilling["Historique"] || []).any? && (forage = drilling["Historique"].select { |h| h[:type] == "Forage" }.first) && !(forage[:fin].dump == "\"\\u{a0}\"") && !(forage[:debut].dump == "\"\\u{a0}\"") && !(forage[:debut] == "n.d.") && !(forage[:fin] == "n.d.")
    
    start_year = forage[:debut].match(/(\d{4})/)[0].to_i
    end_year   = (forage[:fin] || forage[:debut]).match(/(\d{4})/)[0].to_i

    if start_year > end_year
      out["start"] = start_year
      out["start"] = end_year
    else
      out["start"] = start_year
      out["end"] = end_year
    end
  else
    out["start"] = drilling["Année forage"].to_i
    out["end"] = drilling["Année forage"].to_i
  end
  json_data << out

  tab.puts [
    out["number"],
    out["name"],
    out["region"],
    out["latitude"],
    out["longitude"],
    out["company"],
    out["start"],
    out["end"]
  ].join("\t")
end

json.puts JSON.pretty_generate(json_data)