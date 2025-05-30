# ble_control_app
1. User Interface & Appearance
•	Dark-Theme-Only UI:
o	The entire app uses a fixed dark theme. This means high-contrast text and minimalistic icons designed for clarity and readability.
o	There is no option to change themes or colors. Everything, from backgrounds to buttons, is set to the dark design.
•	Local Assets:
o	All icons, status indicators, and graphics are pre-generated and stored within the app's resources.
o	No fonts, images, or vector resources are fetched from online sources.
2. Bluetooth Connectivity
•	Offline, Multi-Device Discovery:
o	The app continuously scans and lists all available dry fog disinfection devices that support Bluetooth.
o	Because every device is powered by an external power supply, connection reliability is enhanced, and you can assume relatively stable operation.
•	Simultaneous Connections:
o	Enable the app to manage multiple Bluetooth connections at once (e.g., up to nine devices).
o	Each device is managed independently, with its own communication channel for commands and status updates.
•	Permission & Error Handling:
o	The app prompts for and manages Bluetooth permissions locally.
o	Display simple, clear error messages for any connectivity issues, along with a retry mechanism, all handled on-device.
3. Device Management & Session Control
•	Grid View for Devices:
o	The home screen displays a grid of all discovered and paired disinfection devices.
o	Each device tile shows a locally generated icon with a small connection status indicator (green for connected, gray for disconnected).
•	Individual Controls Per Device:
o	Intensity Control: Choose one of four discrete levels (Low, Medium, High, Max) unique to each device.
o	Timer Settings:
	Input a duration (between 5 and 7200 seconds) using either a simple numeric input or a slider, with real-time conversion (e.g., 84 seconds → 1 minute 24 seconds).
o	Session Commands: Start, pause, or stop a session for each device using clear, large action buttons with confirmation dialogs to prevent accidental operations.
•	Simultaneous Sessions:
o	Each device can run its session independently. You may start, adjust, or terminate sessions concurrently across multiple devices without conflicts.
4. Scheduling & Automation
•	Simplified Scheduling (Optional):
o	Include a pared-down scheduling feature that lets users pre-configure a session (timer and intensity) for a given device, with a simple one-time or single scheduled action.
o	All scheduling data is stored locally, and the interface is minimal—focusing only on setting the date/time and duration without elaborate repeat patterns or export functions.
•	User Confirmation:
o	Every scheduling or session activation is confirmed via straightforward popups to ensure the user understands the action before it commits.
5. Session Logging & Local Data
•	Local Session Logs:
o	Each device logs its past sessions, capturing details such as duration, intensity level, and outcome.
o	A minimal dashboard shows the history in a list format with simple filters (recent sessions only).
•	Data Management:
o	Users can manually clear session logs with a “Clear All” button that triggers a confirmation dialog.
o	All logs and schedules reside entirely on the device.
6. Built-In Error Logging
•	Error Logging:
o	The app captures any runtime errors or issues and stores them locally for developers (or for later review in a simple debug view if needed).
o	Users see only minimal error prompts explaining the problem and suggesting a retry.
7. Development & Offline Operation
•	Local Build Environment:
o	All assets, libraries, and code components are stored and built on your PC.
o	No external dependencies (online libraries or API calls) are used at runtime, ensuring the entire app functions entirely offline.
•	Simplicity & Maintainability:
o	The codebase is lean, featuring only the core functionality: multi-device Bluetooth handling, session management per device, and local data logging.
o	The focus is on ease of use: a minimalistic interface, clear instructions, and robust error management to gracefully handle any issues—all without internet access.

===================================================

• Offline, Dark‑Theme‑Only  
  – Use Flutter’s built‑in dark theme (ThemeData.dark()).  
  – Bundle 1–2 basic vector icons (e.g. device, start, stop) in /assets/icons. No online assets or heavy images.

• Bluetooth LE Control (up to 10 devices)  
  – Scan/connect up to 9 BLE “disinfection” devices concurrently.  
  – For each device show a small tile in a scrollable grid. Green dot = connected, grey = disconnected.  
  – Tap tile to open its control view.

• Device Control View  
  – Selector: intensity with 4 TextButtons (Low, Med, High, Max).  
  – Timer: simple numeric TextField (5–7200 s) plus “mm:ss” label.  
  – Three ElevatedButtons: Start, Pause, Stop. Each asks “Are you sure?” before action.  
  – Timer runs in Dart (no animation libraries). When it ends → record success; when stopped early → record stopped.

• Scheduling (Mandatory, but very basic)  
  – On control view add one “Schedule” button.  
  – Let user pick date & time via showDatePicker/showTimePicker, set intensity + duration.  
  – Save schedule locally via sqflite (single table). No repeats, no notifications—just saved data.

• Session Logging  
  – Log each session to SQLite (deviceId, intensity, duration, outcome, timestamp).  
  – On main screen add “Logs” tab: show last 10 entries in simple ListView.  
  – “Clear All” button clears the table after confirmation.

• Permissions & Error Handling  
  – Request Bluetooth & location once at startup. If denied → simple AlertDialog with “Grant permissions” message.  
  – On BLE errors show AlertDialog “Connection failed – Retry?” with Retry button.  
  – Log all exceptions to a small in‑memory list; expose via a hidden long‑press in Settings.

• Internationalization  
  – Support EN, ES, FR, DE, ZH via intl + .arb files.  
  – Auto‑detect locale, allow manual override in Settings. Store choice in SharedPreferences.

• Architecture & Output  
  – One dependency per feature: flutter_blue, intl, sqflite, provider, permission_handler.  
  – Single main.dart with basic routing to 3 screens: Devices, Logs, Settings.  
  – Keep code under ~500 lines, no fancy UI packages.  
  – Provide pubspec.yaml, assets/icons (placeholder SVG/PNG), .arb files, and all Dart code so it compiles immediately in Replit.

Ensure the app is ultra‑light, uses only core Flutter widgets, and runs smoothly on any midrange phone without special hardware. No stub code—every function must work offline out of the box.
