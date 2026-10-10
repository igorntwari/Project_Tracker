# Project Tracker

A modern easy to use Flutter application designed to help teams manage tasks track project progress and monitor important deadlines. 

## Overview

Project Tracker is a local first application that lets you assign tasks to team members, set due dates and monitor deadlines to see if tasks are "On Track" "At Risk" or "Overdue". It is built with simplicity in mind providing a clean dashboard and visual charts to understand project health at a glance.

## Key Features

* Dashboard: Get a quick overview of project progress including key performance indicators and a beautiful custom donut chart.
* Task Management: View search and filter a list of all team tasks easily. 
* Smart Deadline Tracking: Tasks are automatically categorized based on their due dates:
  * On Track: Plenty of time left.
  * At Risk: Due within 2 days.
  * Overdue: Past the deadline.
* Statistics and Charts: A dedicated statistics screen visually breaks down task statuses using a custom built bar chart and lists upcoming deadlines.
* Offline Ready: Uses local SQLite storage (`sqflite`) for mobile platforms ensuring data is saved right on your device. It also includes a web friendly fallback for testing in your browser.
* Profile Management: View logged in user details and access application settings.

## Technology Stack

* Framework: [Flutter](https://docs.flutter.dev/get-started/install) and Dart
* Database: SQLite (`sqflite` package) for mobile and in memory storage for web testing.
* State Management: Native Flutter StatefulWidgets and FutureBuilders for smooth and asynchronous data loading without extra heavy libraries.

## Project Structure

* `lib/models/`: Contains the data blueprints like `TaskModel` and `User`.
* `lib/database/`: Holds the `DatabaseHelper` which manages saving loading and updating data.
* `lib/screens/`: All application visual pages like `HomeScreen` `TaskListScreen` `TaskStatisticsScreen` and `ProfileScreen`.
* `lib/widgets/`: Reusable UI components used across different screens.

## How to Run

1. Ensure you have Flutter installed on your machine.
2. Clone this repository to your local machine.
3. Open your terminal and navigate to the project folder.
4. Run the following command to get the necessary packages:
   ```bash
   flutter pub get
   ```
5. Run the app on your preferred emulator or device:
   ```bash
   flutter run
   ```

## About This Project

This project was built with a focus on clean UI UX and fundamental mobile development concepts. It demonstrates how to integrate a local database build custom painted widgets like charts and manage application state using standard Flutter tools. It serves as a great example of a complete functional app structure.

## Scrum Board

You can track our progress and upcoming features on our Trello board: [Project Tracker Scrum Board](https://trello.com/b/bgfI9syf/project-tracker)
