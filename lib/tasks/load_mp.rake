require 'open-uri'

namespace :load_mp do
  desc "Load mp https://scrapermp.rada4you.org/"
  task :all => :environment do
    data_mps = JSON.load(open("https://scrapermp.rada4you.org/national"))
    data_mps.each do |m|
      if m["end_date"].nil?
        end_date = "9999-12-31"
      else
        end_date = m["end_date"]
      end
      mp = Mp.find_or_create_by(deputy_id: m["id"], first_name: m["given_name"], middle_name: m["patronymic_name"], last_name: m["family_name"], faction: m["faction"],  okrug: m["area"], start_date: m["start_date"])
      mp.update(end_date: end_date)
    end
  end
  desc "Load picture image deputy"
  task :image => :environment do
    mps = JSON.load(open("https://scrapermp.rada4you.org/national"))
    mps.each do |m|
      p m["image"]
      photo = MiniMagick::Image.open(URI.encode(m["image"]))
      photo.resize "200x200"
      photo.format 'png'
      photo.write("#{Rails.root}/public/image/#{m["id"]}.png")
    end
  end
end
