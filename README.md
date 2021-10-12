# OneSpark - An Ecosystem for Social Good - HackDavis 2021 Winner for Best Use of Google Cloud

This is an MVP product submitted to HackDavis 2021 - Hack for Social Good hosted by University of California, Davis in January 2021.

This is an MVP, not a completed product.

![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/Onespark.png?raw=true)

# Team
* UI/Mobile Developer: **Vu Nguyen**
* Ideation, UX: **Da Thi Hoang**
* Presentation: **Luan Nguyen**

# Presentation

[Click here to watch our presentation](https://www.youtube.com/watch?v=tB1SekBKAQo)
## Inspiration
If, like our team members, you have led or participated in a social initiative before, you probably share our opinion that establishing a social project is not easy. Social projects that just start out face countless problems regarding establishing credibility, doing publicity, recruiting team members, and finding funding to name a few.

We believe that doing good should not be so difficult, especially given the vibrant community of people who care about social good (like all of you who participated in this Hackathon for social good!).

![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%281%29.jpg?raw=true)

## What it does

That is why we built OneSpark, an ecosystem for social good where people can help each other make their social initiative more impactful. OneSpark makes it easy for social initiatives to create their first public profile and broadcast their project ideas to a community who cares. Social impact groups can also find partners, mentors and donors for their project through the platform, hence receiving the support they need to launch their project.

![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%282%29.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%285%29.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%286%29.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%287%29.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%288%29.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%289%29.jpg?raw=true)

## How we built it

OneSpark is a cross-platform mobile app that was mainly built by **Flutter** framework. We used **Firebase authentication** to allow app users to create an account and store their information in **Google Cloud Firestore database**. All others data in the app are also stored in **Firestore** to make sure data is synced real-time to the app. The messaging system between organizations, mentors and users also utilize the **Firestore** for real-time chatting. We managed to work with **Google Cloud Functions** to set up the backend for **Twilio Programmable Video API**, so that we don’t need to generate the token by testing tools every time we set up a meeting room. The cloud functions do all the work to create a token, create a meeting room by sending requests to **Twilio REST API**.

![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%284%29.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%283%29.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%2810%29.jpg?raw=true)![enter image description here](https://github.com/vunguyen7797/hackdavis2021_onespark/blob/master/gallery%20%2811%29.jpg?raw=true)

## Challenges we ran into

Since the app has many different user groups and components, we spent a lot of time wireframing and debating the user flows and features of the app to make sure it is intuitive and useful to all groups of users, including social project groups, donors, and mentors.

**Twilio API** was also a new territory for us. It took us a while to deal with the backend to generate the token automatically. We found the solution by using **Google cloud function** but none of us had experiences with deploying **Google cloud function** before. We wanted to make the app with a minimal but eye-catching UI, thus, it required a lot of speed coding for the front-end tasks.

Also, we are from different time zones (US Central Time, US Eastern Time and Moscow, Russia). Some long nights for some of us!

## Accomplishments that we're proud of

We managed to successfully deploy the **Google Cloud functions** for the **Twilio Programmable Video API**. Also, we got most of the main functions working such as direct messaging, video meeting room, news feed for the project information page,... in the demo app that can basically demonstrate our ideas.

## What we learned
We learned how to deploy backend functions on Google Cloud Functions. We also learned how to reduce the amount of time for coding but got the expected results by organizing well the code and making more reusable pieces of code.

We also realize that ideation and pitching processes take a lot of time, and one should not procrastinate till the last minute!


# Demo Features:
* Direct message for Supporters, Organizers, Mentors and Support-seekers.
* Video meeting room.
* News feed for the social project information page.
* Supporters, mentors search page.

# Built With
* Flutter
* Firebase authentication
* Google Cloud Firestore
* Google Cloud Functions
* Twillio Programmable Video API 
