Now that the color palette is confirmed, prepare the Flutter/Dart design direction for the Sprint 1 mobile app screens for “UTM Paws-itive”.

Important technical requirement:
Use Flutter with Dart.
Do NOT use React Native.
Do NOT use JavaScript or TypeScript.
Use Flutter Material widgets.
Use mobile frame size close to 390 × 844.
The generated output should be easy to convert into Flutter code.

Do NOT generate all screens at once.
First, create a screen list and Flutter design system based on the selected palette.

App name:
UTM Paws-itive

App purpose:
A mobile app for UTM students, staff, and volunteers to report, track, and view stray animals on campus.

Sprint 1 screens that must be designed:

1. Splash / Welcome Screen
2. Login Screen
3. Register Account Screen
4. Home / Animal List Screen
5. Report Stray Animal Screen
6. Animal Profile Screen
7. Success / Confirmation Screen or Modal
8. Empty State Screen

Flutter design system to prepare:
- ThemeData color scheme
- AppBar style
- TextTheme:
  - App title
  - Screen title
  - Section title
  - Body text
  - Caption text
  - Button text
- Button styles:
  - ElevatedButton
  - OutlinedButton
  - TextButton
  - FloatingActionButton
- Input field styles:
  - TextField normal
  - TextField focused
  - TextField error
- Card style:
  - Animal report Card
  - Profile detail Card
- Status chips:
  - Healthy
  - Needs Feeding
  - Injured
  - Sick
  - Unknown
- Icons:
  - pets
  - location_on
  - camera_alt / image
  - health_and_safety
  - person / logout
  - search / filter_list

Screen requirements:

1. Splash / Welcome Screen
Purpose:
Introduce the app and show the UTM Paws-itive identity.

Required Flutter UI elements:
- Scaffold
- Center/Column layout
- Paw/pets icon or simple logo placeholder
- Text: UTM Paws-itive
- Text tagline: “Report, Track, and Care for Stray Animals in UTM”
- ElevatedButton: Get Started

2. Login Screen
Purpose:
Allow registered users to log in.

Required Flutter UI elements:
- Scaffold
- AppBar or custom header
- TextField for email
- TextField for password
- ElevatedButton: Login
- TextButton: Create new account
- Error message style for wrong credentials

Related use case:
UC02 Login / Logout

3. Register Account Screen
Purpose:
Allow new users to create an account.

Required Flutter UI elements:
- Scaffold
- AppBar
- TextField: Full Name
- TextField: Email
- TextField: Password
- TextField: Confirm Password
- DropdownButtonFormField or SegmentedButton for role:
  Student / Staff / Volunteer
- ElevatedButton: Register
- TextButton: Already have an account? Login

Related use case:
UC01 Register Account

4. Home / Animal List Screen
Purpose:
Show all reported animals in the system.

Required Flutter UI elements:
- Scaffold
- AppBar with title and logout/profile icon
- Search TextField
- FilterChip list:
  All, Cats, Dogs, Healthy, Needs Help
- ListView.builder
- Animal report Cards
- Each Card should include:
  - Animal image placeholder using Container or ClipRRect
  - Animal name or label
  - Location row with location_on icon
  - Health status Chip
  - Short description
  - Date reported
- FloatingActionButton.extended: Report Animal

Related use case:
UC04 View Animal List

5. Report Stray Animal Screen
Purpose:
Allow users to submit a stray animal report.

Required Flutter UI elements:
- Scaffold
- AppBar
- Image upload placeholder Container
- DropdownButtonFormField or SegmentedButton:
  Cat / Dog / Unknown
- TextField: Location
- TextField: Description with maxLines
- DropdownButtonFormField for health status:
  Healthy, Needs Feeding, Injured, Sick, Unknown
- ElevatedButton: Submit Report
- Validation message style for missing image/location/description

Related use case:
UC03 Report Stray Animal

6. Animal Profile Screen
Purpose:
Show full details of a selected reported animal.

Required Flutter UI elements:
- Scaffold
- AppBar with back button
- Large image placeholder
- Text: Animal name or label
- Text: Animal type
- Row with location icon and location text
- Health status Chip
- Description Card
- Date reported
- Reported by
- Optional OutlinedButton: Contact Volunteer
- Optional ElevatedButton: Mark as Seen

Related use case:
UC05 View Animal Profile

7. Success / Confirmation Screen or Modal
Purpose:
Confirm that a report has been submitted.

Required Flutter UI elements:
- AlertDialog or full Scaffold success screen
- Success icon
- Text: “Animal report submitted successfully”
- ElevatedButton: View Animal List
- OutlinedButton: Submit Another Report

8. Empty State Screen
Purpose:
Show when there are no animal reports.

Required Flutter UI elements:
- Scaffold or reusable widget
- Friendly paw/pets icon
- Text: “No animal reports yet”
- Text: “Be the first to report a stray animal in UTM”
- ElevatedButton: Report Animal

Design requirements:
- Clean spacing
- Rounded cards
- Friendly icons
- Easy-to-read text
- Consistent colors from the selected palette
- Flutter Material 3 look
- Suitable for a student Sprint 1 prototype
- Realistic enough for a demo presentation

For now, only prepare the Flutter design system and screen list.
Do not generate all final screens until I ask for each screen separately.