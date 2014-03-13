Battlefield 4 get-stats
=======================

Pulls weapon stats for a player and outputs to a csv file.

Currently it provides an easy way to generate a spreadsheet of all the weapons that have attachments and informs you of how many attachments are left to unlock for each weapon along with additional information.

## Configuration

You need one piece of information before being able to get stats from a specific soldier. You need what is refered to as a **persona id**. It belongs in the configuration file. To get this information you can visit a soldiers page in **Battlelog** and you will be able to see it in the url as highlighted the image below.

![battlelog](https://dl.dropboxusercontent.com/u/3413996/github_images/persona.png "How to get persona id on Battlelog")

## Running

A gem file is provided so all you need to do is run `bundle install` in the directory to get the required libraries and then you are able to run the program by doing `ruby scrape.rb`.
