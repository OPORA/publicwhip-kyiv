# frozen_string_literal: true

namespace :load_division do
  desc 'Load votes'
  task :votes, %i[from_date to_date] => :environment do |t, args|
    from_date = args[:from_date] ? Date.parse(args[:from_date]) : Division.order(:date).pluck(:date).last + 1
    to_date = if args[:to_date]
                Date.parse(args[:to_date])
              elsif !args[:from_date]
                Date.today
              else
                from_date
              end

    (from_date..to_date).each do |date|
      divisions = JSON.load(open("https://scrapervoted.rada4you.org/vote_events/#{date}"))
      vote_events = divisions["vote_events"]
      p "Loading #{vote_events.count} vote_events  #{date.strftime("%F")}... "
       vote_events.each do |v_e|
         division = Division.find_or_initialize_by(number: v_e["identifier"], date: DateTime.parse(v_e["start_date"]).strftime("%F") )
         division.name = v_e["title"]
         division.clock_time = DateTime.parse(v_e["start_date"]).strftime("%T")
         division.result = v_e["result"]
         division.save!

         votes = v_e["votes"]
         p "Loading #{votes.count} votes..."
         possible_members = Mp.where('? >= start_date and end_date >= ?', division.date, division.date)
         division.votes.destroy_all
         votes.each do |v|
           #p v["voter_id"]
           member = possible_members.find_by!(deputy_id: v["voter_id"])
           if option = popolo_to_publicwhip_vote(v["option"])
             division.votes.create!(deputy_id: member.id, vote: option)
           end
         end
       end
    end
  end
end
def popolo_to_publicwhip_vote(string)
  case string
  when "yes"
    "aye"
  when "no"
    "against"
  when "abstain"
    "abstain"
  when "absent"
    "absent"
  when "not voting"
    "not_voted"
  else
    raise "Unknown vote option: #{string}"
  end
end