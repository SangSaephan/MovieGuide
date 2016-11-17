# MovieGuide

##Description:
A movie guide app that displays an overview of movies currently in theaters; written in Swift as a tutorial project for MobileSpace. This app was built to learn the concepts of making API calls and displaying that data within the app. API calls were made using Alamofire and AlamofireImage was used to display images. In addition, Realm was implemented to allow persistence.

APIs Used: OMDb, The Movie DB

##Demo:
![](MovieGuide.gif)

##Features/Functions Added:
- Pull-to-Refresh (makes a call to the API for new movies, if available)
- Movie release date, as well as movie rating
- Sort functions (A-Z, Movie Rating, Movie Release Date)
- Additional API calls to retrieve more movie info

##Bugs Fixed:
- Duplicate movies being added to Realm database
