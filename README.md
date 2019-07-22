# analysis_on_google_play_store_apps
Analysis on apps from google play store and find the relationship between different features to gain more profit for developer. 

1 Data Source and Data Description
This dataset is from Kaggle datasets, which is public datasets scarped from the Google Play Store. There are two datasets: google play store dataset and google play store user review dataset. The first dataset contains the information of applications on Google Play. The second dataset contains the first “most relevant” 100 reviews for each app. Here is the description of two datasets:

	   Kind of data	                                        Number of records	                   Number of features
    Google play store dataset	tabular	                                10.8k	                                 13
    Google play store user review dataset textual	                64.2k	                                  5

For each dataset, there are many features. Here are the feature name and their description in google play store dataset: 

         Feature name	                                       Feature description
           App	                                             Name of application
         Category                                      	Category the app belongs to
          Rating	                                       Overall user rating of the app
          Reviews                                      	Number of user reviews for the app
           Size	                                               Size of the app
          Installs                              	Number of user downloads/installs for the app
           Type	                                               Paid of free
           Price                                            	Price of the app
        Content rating	                        Age group the app is targeted at (Children/Mature 21+/Adult)
          Genres	                                        Genres that an app belongs to
        Last updated	                           Date when the app was last updated on Play Store
        Current ver	                            Current version of the app available on Play Store
        Android ver	                                      Min required Android version

Here are the feature name and their description in google play store user review dataset:

        Feature name	                                      Feature description
           App	                                            Name of application
       Translated_review                          	User review (translated into English)
         Sentiment                                      	Positive/Negative/Neutral
       Sentiment_polarity	                                 Sentiment polarity score
     Sentiment_subjectivity                            	Sentiment subjectivity score


2 Questions to answer
After observing these datasets, we want to explore the which kinds of apps people wants to download. There are three questions we want to explore:

Q1) Does the free applications will be poplar? What price range of apps will be suitable that people are likely to paid and download? 

Q2) What kinds of apps will be poplar? Tools or entertainments?

Q3) what is the relationship between number of installs and other features?

Q4) what kinds of apps will get better review? And does apps getting better review can have the largest number of installs?



