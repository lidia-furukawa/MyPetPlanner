# MyPetPlanner

This app was developed as Udacity's iOS Developer Nanodegree final project.
MyPetPlanner is an iOS daily planner app for your pet(s). It lets you keep track of your pet(s) routine care, such as feeding, grooming, parasites control and veterinary care.
You can add calendar events to remind you of important pets' healthcare activities.
You can also track and categorize expenses to help monitor and control your budget.
MyPetPlanner helps keep your pet healthy and happy!

## Features
- **My Pets Tab**:
   - Add a new pet (cat or dog).
     - Add relevant information, such as the pet's name, birthday, gender, breed, weight and height.
     - Display a scrollable list with cat/dog breeds from networked APIs.
     - Select a pet picture from the device's photo library or take one with the camera.
   - Display the user's list of added pets.
   - Tap to select a pet (the selected pet is persisted between runs).
   - Swipe to edit or delete a pet.
   - Sort the list of added pets by name (A-Z) or type (Cat-Dog). 
- **Healthcare Tab**:
   - Display the healthcare categories (Food, Grooming, Parasite Control and Vet Care) in a list.
   - Add a healthcare subcategory for the selected pet.
     - Add relevant information, such as the care name, frequency, cost and expense date.
     - Track expenses: automatically calculate future expenses from the expense date until a set final date.
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
The app can run without any additional setup.

## Sources/Dependencies
**[Dog API](https://dog.ceo/dog-api/)**
- Provide the list of dog breeds

**[The Cat API](https://thecatapi.com/)**
- Provide the list of cat breeds

**[Charts Library by Daniel Gindi](https://github.com/danielgindi/Charts)**
- Pie Chart in the Expenses Tab.
