require 'open-uri'
require 'rubygems'
require 'hpricot'

f = File.open("url_list.txt")
urls = f.read.split("\n")
f.close
dataset = {}
urls.each do |url|
  doc = Hpricot(open(url))
  user_name = url.scan(/.me\/(.*)/).flatten.first
  name = doc.at("div/#basics/h2").nil? ? "No Name" : doc.at("div/#basics/h2").innerHTML
  location = doc.at("div/#basics/p").nil? ? "No Location" : doc.at("div/#basics/p").innerHTML.strip
  description = doc.at("div/.module .bio/p").nil? ? "No Description" : doc.at("div/.module .bio/p").innerHTML.strip
  questions = {}
  doc.search("div/#questions/li").each do |qa_set|
    question = qa_set.at("h2").innerHTML.gsub(/(<[^>]*>)|\n|\t/s) {""}
    answer = qa_set.at("p").innerHTML.gsub(/(<[^>]*>)|\n|\t/s) {""}
    questions[question] = answer
  end
  dataset[user_name] = [name, location, description, questions]
end
$final_file = ""
dataset.each_pair do |k,v|
  $final_file += "="*50
  $final_file += "\n"+k+"\n"+dataset[k][0]+"\n"+dataset[k][1]+"\n"+dataset[k][2]
  $final_file += "\n"+"."*50
  dataset[k][3].collect{|kk,vv| $final_file += "\n"+kk+"\n\n"+vv+"\n"+"-"*50}
  $final_file += "="*50  
end
f = File.open("formspring_results.txt", "w+")
f.write($final_file)
f.close