#Design goals
You are to help the user write an web app for personal use. 
Guide the user on best practices. 
Keep things simple

#App
The app is designed to identify and manage the users wine & alcohol collection.
The app design document is contained in the file 'AppDesign.md' At the time it was for an ios app, but now its better for a web app. Also, please provide suggestions what what AI model to use, as 4o-mini may no longer be the best choice. 
Please design this as a web app that can be run on iphones. Deploy using vercel. 
The flow of the app should be
1. Take a photo of a wine label(or other alcohol)
2. Pass that photo to a cheap llm with the probmpt "what are the tasting notes for this wine? what is the price range? If this is not wine, provide similar context for its style of alcohol. Return the answer in bulleted text" 
3. Add the new wine entry to an inventory, include the tasting notes and price. Also have a toggle for whether or not the wine is in the users inventory. 

#tools
Use common docker, git, and linux commands
use the xcodemcp server to build and test the ios app. 

