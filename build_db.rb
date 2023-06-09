#!/usr/bin/env ruby

require "open-uri"
require "csv"

DB_URI = "https://storage.googleapis.com/prod-geoservice-lightship/POIsLightshipDevPortal.csv"
LOCAL_DB = "./POIsLightshipDevPortal.csv"
MAX_TIME = 60*60 # 1h

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


db = loadDB
puts "parse"
csv = CSV.parse(db, headers: true, skip_blanks: true )
keys = csv.map { |row| "\"#{(row[6].to_f*1e6).to_i.to_s(36)}_#{(row[5].to_f*1e6).to_i.to_s(36)}\""}

puts "write"
File.open(RESULT, "wt") { |file| 
    file.write("export const lightshipDB = new Set([\n    ")
    file.write(
        keys.each_slice(5)
            .to_a
            .map {|x| x.join(",")} 
            .join(",\n    ")) 
    file.write("]);\n")
}
