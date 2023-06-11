#!/usr/bin/env ruby

require "open-uri"
require "csv"

DB_URI = "https://storage.googleapis.com/prod-geoservice-lightship/POIsLightshipDevPortal.csv"
LOCAL_DB = "./POIsLightshipDevPortal.csv"
MAX_TIME = 12 * 60*60 # 12h
MAX_ENTRIES_PER_LINE = 24

RESULT = "./src/Database.ts"


def loadDB
    if !File.exist?( LOCAL_DB ) || (Time.now - File.mtime(LOCAL_DB)) > MAX_TIME then
        puts "download DB"
        db = URI.open(DB_URI) { |io| io.read }
        File.open(LOCAL_DB, "wb") { |file| file.write(db) }
    end

    puts "load DB"
    db = File.open(LOCAL_DB, "rt") { |io| io.read }
    return db
end

def generateID(rows)
    return rows.map { |row| "\"#{(row[6].to_f*1e6).to_i.to_s(36)}#{(row[5].to_f*1e6).to_i.to_s(36)}\""}
end

def getIDList(keys)
    keys.sort!
    keys = grouping(keys, 1) 
    keys.map{ |x| x.join(",")}.join(",\n    ")
end


def grouping(keys, level) 
    result = []
    keys = keys.group_by { |i| i[level]}

    keys.values.each { |x| 
        if x.length > MAX_ENTRIES_PER_LINE then 
            result.push *grouping(x,level+1) 
        else
            result.push x
        end
    }
    return result
end


db = loadDB
puts "parse"
csv = CSV.parse(db, headers: true, skip_blanks: true )
production = csv.select { |row| (row[4] || "").upcase == "PRODUCTION" }
others = csv.select { |row| (row[4] || "").upcase != "PRODUCTION" }

puts "write"
File.open(RESULT, "wt") { |file| 
    file.write("export const lightshipDBProd = [\n    ")
    file.write(getIDList(generateID(production)))
    file.write("\n];\n")

    file.write("\nexport const lightshipDBRest = [\n    ")
    file.write(getIDList(generateID(others))) 
    file.write("\n];\n")

}
