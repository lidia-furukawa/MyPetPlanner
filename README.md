# MyPetPlanner

One to two paragraph statement about your product and what it does.
MyPetPlanner is an app designed to 

## Features
- **My Pets Tab**:
   - Add a new pet (cat or dog).
     - Add relevant pet information, such as its name, birthday, gender, breed, weight and height.
     - Display a picker scrollable list with cat/dog breeds from networked APIs.
     - Select a pet picture from the device's photo library or take one with the camera.
   - Display the user's list of added pets.
   - Tap to select a pet [x] and interact with other app's features.
   - Swipe to edit or delete a pet.
   - Sort the list of added pets by name (A-Z) or type (Cat-Dog). 
- **Healthcare Tab**:
   - Display the healthcare categories (Food, Grooming, Parasite Control and Vet Care) in a list.
   - Add a healthcare subcategory for the selected pet.
     - Add relevant information, such as the care name, frequency, cost and expense date.
     - Track expenses: automatically calculate future expenses from the expense date through a set final date.
     - Add calendar event: create a local *MyPetPlanner* calendar in the device and add a event to it.
- **Calendar Tab**:
   - Display the selected pet's calendar events (previously added in the Healthcare Tab) in a list.
   - Filter calendar events by date.
   - Swipe to edit or delete a calendar event.
- **Expenses Tab**:
   - Display the selected pet's expenses (previously added in the Healthcare Tab) in a pie chart and a list.
   - Filter expenses by date.
   - Sort expenses by healthcare category or subcategory.
   - Display the total expenses sum for all categories or subcategories.

## Requirements
- iOS 12+
- Xcode 10.3

## Installation
###CocoaPods
You can use CocoaPods to install Charts by adding it to your Podfile:
```
platform :ios, '9.0'
use_frameworks!
pod 'Charts', '~>3.3.0'
```

## Dependencies


## Meta
Lidia Furukawa – lidia.furukawa@gmail.com

Distributed under the XYZ license. See [LICENSE]() for more information.

https://github.com/lidia-furukawa
