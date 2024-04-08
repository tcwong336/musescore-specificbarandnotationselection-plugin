# About the Plugin
This plugin aims to help visually impaired persons to read music scores in MuseScore. 

Functions included:
1. Select a range of measure
2. Set tempo
3. Set staff(current version only provide 2 staff)
4. View music notation beat by beat
   
## Getting Started
### MuseScore Desktop App
This plugin requires [MuseScore 3 or MuseScore 4](https://musescore.org/en).

### Loading Plugin
To use the plugin, download the SpecificBarAndNotationSelection file and move it into the default plugin directories.

#### For MuseScore 3
1. Open the MuseScore 3
2. Open the `Plugins` tab and click `Plugin Manager`,
3. Tick `SpecificBarAndNotationSelection` and click `OK`.
4. Open the `Plugins` tab again and click `SpecificBarAndNotationSelection`
   
Detailed steps can be found [here](https://musescore.org/en/handbook/3/plugins#overview).

#### For MuseScore 4
1. Open the MuseScore 4
2. Select `Plugins` in `Home` tab
3. Search for `Specific bar and notation selection` and enable it.
<img width="300" alt="Screenshot 2024-04-07 at 23 46 40" src="https://github.com/tcwong336/colab_FashionMINST/assets/130147784/77e6c1f5-8f6f-4e04-bee7-01d27be1ce08">
  
4. Open a non-empty score
5. Open the `Plugins` tab and click `Specific bar and notation selection`
   
Detailed steps can be found [here](https://musescore.org/en/handbook/3/plugins#overview).

## How To Control the Plugin
In the interface, users are required to input and navigate the interface using arrow keys. 
For screen readers, please view [MuseScore 4 Accessibility](https://musescore.org/en/handbook/4/accessibility) for the required screen readers of your platform.
### Important Keys for screen readers users
- Since the current version of MuseScore 4 does not allow accessibility for the plugin, screen readers cannot access the plugin in MuseScore 4.
- Please use this plugin on MuseScore 3 for screen reader users.
- Users are only required to input, click, and navigate the interface using arrow keys. Please refer to the corresponding screen reader document for detailed commands.
- Users must set the screen reader to switch on or off in the plugin to indicate as using the screen reader or not. If the screen reader is used but set as off, the screen reader will not provide feedback on the current action.

## Plugin Interface
### Home Page
On this page, users can learn more about, start, and quit this plugin. It is also a brief introduction to this file.
<img width="500" alt="Screenshot 2024-04-07 at 17 29 49" src="https://github.com/tcwong336/colab_FashionMINST/assets/130147784/d2acf273-e5d5-40bc-8230-4cd56bc9fb0b">
1. To understand the plugin features, click `Learn More`. New users are recommended to read before starting.
2. To start the plugin, click `Start`. Ensure a non-empty score is opened. Scores with all rests are considered as empty as well. Otherwise, the plugin cannot start
3. Click `Quit` to quit the plugin if needed.

Examples: Please refer to this YouTube [link]().

### Start Page (Specific Bar Selection)
On the start page, users can play a specific range of measures with a certain tempo and staff.
<img width="500" alt="Screenshot 2024-04-07 at 18 17 53" src="https://github.com/tcwong336/colab_FashionMINST/assets/130147784/4b8d4dca-3762-4788-885e-725fc8a645e1">
1. Click `Start` on the [home page](#home-page).
2. Input start measure, end measure, tempo and select click. The default value is used for blank input. Users are recommended to select a small range of measures.
3. Click `Reset` to reset to default if needed
4. Click `Set` on the start page to confirm input. If the input is invalid, a pop-up message is shown for the remainder.
5. A temporary score is created as not to affect the original score. Return to original score if needed.
6. To play or stop the selected range of measure, click `SPACE`. Also, click `HOME`(Windows) or `Fn`+`→` to rewind to the beginning of the score if needed. 

Examples: Please refer to this YouTube [link]().

### View Music Notation Page (Specific Beat Notation)
On this page, users can view detailed notation of beats on specific measures.
<img width="500" alt="Screenshot 2024-04-07 at 17 30 39" src="https://github.com/tcwong336/colab_FashionMINST/assets/130147784/d2029493-f649-4444-8067-3473c21d28c1">
1. Ensure the current score is the original score but not the temporary score.
2. Input a specific start measure in the start measure row on start if needed. Users can still view the notation of the previous measure even start measure is selected.
3. Click the `View detailed music notation by beat` on [start page](#start-page-specific-bar-selection).
4. Key signature, time signature, detailed right staff notation of certain beats, and detailed left staff notation of certain beats are shown. Notations are shown in order of tick.
5. Click `Previous Beat` or `Next Beat` to view the notation of the previous beat or next beat.

Examples: Please refer to this YouTube [link]().



## Common Questions
**Question:** No feedback when the button is clicked.

**Answer:** Please ensure you have turned the screen reader switch on the plugin. If the screen reader switch is off, the button is clicked but without feedback from the screen reader.

**Question:** Cannot play the selected range of measure.

**Answer:** Please ensure the current score is not the temporary score. Please try to click the `Reset` button on the start page or reopen the plugin.

**Question:** Cannot view the specific beat of the selected measure.

**Answer:** Please ensure the current score is not the temporary score and the measure is input in the start measure row. Please try to click the `Reset` button on the start page or reopen the plugin.


## Changelog
v1.0  7-4-2024

## License
MIT

## Contact
If any problems or suggestions, please feel free to complete this [Google Form](https://forms.gle/LWVEcohQy44ne4126). I will update you as soon as possible.

### **Wish you have a great experience using this plugin. Keep your passion for music and learning instruments!** 
