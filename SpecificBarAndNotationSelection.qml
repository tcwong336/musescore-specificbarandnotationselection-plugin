import MuseScore 3.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import Qt.labs.settings 1.0
import QtQuick.Extras 1.4

MuseScore {
    menuPath: "Plugins.SpecificBarAndNotationSelection"
    version: "1.0"
    description:"Select specific range of measure and notation by beat"
    //requiresScore: true
    id: pluginscope

    property bool allowScreenReader: true
    property bool onScreenReader: false
    property int screenWidth: Screen.desktopAvailableWidth
    property int screenHeight: Screen.desktopAvailableHeight
    property int defaultWidth: 850
    property int defaultHeight: 500

    property string orgScoreName
    property int timeSigNum
    property int timeSigDen

    property int maxMeasure
    property int endMeasure: maxMeasure
    property int startMeasure: 1
    property int defaultTempo:120
    property int curTempo:120
    property int curClef: -1

    property int tempBeat: 1//select a measure
    property string tempRightNotes: ""
    property string tempLeftNotes: ""
    property string beatInfo: ""
    property string beatDetailed: ""
    property string beatText: ""
    property int nextTick
    property int startBeat
    property int endBeat
    property bool leftStartSlur: false
    property bool rightStartSlur:false
    property var tieTick: [] 
    property var tieTickPitch: []
    property var tieTickIndex: 0

    property string tempScoreName:"TEMP Score"
    property var c
    property var tempScore
    property var newTemp: {
        "create": false,
        "orgStartMeasure": 1,
        "orgEndMeasure": curScore.nmeasures,
    } //whether a new temp is created(for situation that select another range of mesure)

    property var noteName: [
        // "C",
        // "C♯",
        // "D",
        // "D♯",
        // "E",
        // "F",
        // "F♯",
        // "G",
        // "G♯",
        // "A",
        // "A♯",
        // "B"
        "F♭",
        "C♭",
        "G♭",
        "D♭",
        "A♭",
        "E♭",
        "B♭",
        "F",
        "C",
        "G",
        "D",
        "A",
        "E",
        "B",
        "F♯",
        "C♯",
        "G♯",
        "D♯",
        "A♯",
        "E♯",
        "B♯"        
    ]
    //[keysig+7]
    property var keySig: [
        "F Major, with B♭",
        "B♭ Major, with B♭ E♭",
        "E♭ Major, with B♭,E♭,A♭",
        "A♭ Major, with B♭,E♭,A♭,D♭",
        "D♭ Major, with B♭,E♭,A♭,D♭,G♭",
        "G♭ Major, with B♭,E♭,A♭,D♭,G♭,C♭",
        "C♭ Major, with B♭,E♭,A♭,D♭,G♭,C♭,F♭",
        "C Major",
        "G Major, with F♯",
        "D Major, with F♯,C♯",
        "A Major, with F♯,C♯,G♯,",
        "E Major, with F♯,C♯,G♯,D♯",
        "B♭ Major, with	F♯,C♯,G♯,D♯,A♯",
        "F♯ Major, with F♯,C♯,G♯,D♯,A♯,E♯",
        "C♯ Major, with F♯,C♯,G♯,D♯,A♯,E♯,B♯",
    ]

    function getClefText() {
        if (curClef == -1) {
            return qsTr("Both Staff (Both Hands)")
        } else if (curClef == 0) {
            return qsTr("Top Staff (Right Hand)")
        } else if (curClef == 1) {
            return qsTr("Bottom Staff (Left Hand)")
        }
    }

    function createTempScore() {
        tempScore = newScore(tempScoreName, "piano", endMeasure - startMeasure + 1);
        tempScore.addText("title", "Temporary Score for Plugin");
        var tempCursor = tempScore.newCursor();
        tempCursor.rewind(0);
        changeMeasureTempo()

    }

    function playMeasure() {
        var temp=0
        temp=endMeasure==newTemp.orgEndMeasure?division / timeSigDen * 4:0
        
        curScore.startCmd();
        curScore.selection.selectRange(division / timeSigDen * 4 * timeSigNum * (startMeasure - 1), division / timeSigDen * 4 * timeSigNum * endMeasure+temp, 0, 2)
        curScore.endCmd();

        cmd("copy")
        createTempScore();
        newTemp.create = true
        cmd("select-all");
        cmd("paste");
    }

    function changeMeasureTempo() {
        var tempC = curScore.newCursor()
        tempC.rewindToTick(0)
        var tempTempo=""
        var existTempo=true

        for (var i in tempC.segment.annotations) {
            if (tempC.segment.annotations[i].type == Element.TEMPO_TEXT) {
                tempTempo=tempC.segment.annotations[i]
                break;
            }
        }

        if(tempTempo==""){
            tempTempo = newElement(Element.TEMPO_TEXT)
            existTempo=false
        }
        tempTempo.text = "<sym>metNoteQuarterUp</sym> = " + curTempo
        tempTempo.color = "#ffcc33"
        tempTempo.visible = visible
        if (!existTempo) {
            tempC.add(tempTempo);
        }
        tempTempo.tempo = curTempo/60
        tempTempo.followText = true


    }

    function getNoteLength(symbolName) {
        var k
        for (k in symbolName) {
            if (symbolName[k] == "t") {
            break
            }
        }
        return symbolName.substr(4, symbolName.length - k - 3)
    }

    function setClef() {
        //right
        if (curClef == 0) {
            curScore.startCmd()
            curScore.selection.selectRange(0, division / timeSigDen * 4 * timeSigNum * tempScore.nmeasures+division / timeSigDen * 4, 1, 2)
            curScore.endCmd()
            for (var i in curScore.selection.elements) {
                if (curScore.selection.elements[i].type == Element.NOTE) {
                    curScore.selection.elements[i].play = false
                }
            }
            curScore.startCmd()
            curScore.selection.selectRange(0, division / timeSigDen * 4 * timeSigNum * tempScore.nmeasures+division / timeSigDen * 4, 0, 1)
            curScore.endCmd()
            for (var i in curScore.selection.elements) {
                if (curScore.selection.elements[i].type == Element.NOTE) {
                    curScore.selection.elements[i].play = true
                }
            }
        }
        //left
        else if (curClef == 1) {
            curScore.startCmd()
            curScore.selection.selectRange(0, division / timeSigDen * 4 * timeSigNum * tempScore.nmeasures+division / timeSigDen * 4, 0, 1)
            curScore.endCmd()
            for (var i in curScore.selection.elements) {
                if (curScore.selection.elements[i].type == Element.NOTE) {
                    curScore.selection.elements[i].play = false
                }
            }
            curScore.startCmd()
            curScore.selection.selectRange(0, division / timeSigDen * 4 * timeSigNum * tempScore.nmeasures+division / timeSigDen * 4, 1, 2)
            curScore.endCmd()
            for (var i in curScore.selection.elements) {
                if (curScore.selection.elements[i].type == Element.NOTE) {
                    curScore.selection.elements[i].play = true
                }
            }

        }
        //both
        else if (curClef == -1) {
            curScore.startCmd()
            curScore.selection.selectRange(0, division / timeSigDen * 4 * timeSigNum * tempScore.nmeasures+division / timeSigDen * 4, 0, 2)
            curScore.endCmd()
            for (var i in curScore.selection.elements) {
                if (curScore.selection.elements[i].type == Element.NOTE) {
                    curScore.selection.elements[i].play = true
                }
            }
        }

        curScore.startCmd()
        curScore.selection.clear()
        curScore.endCmd()
    }

    //check whether the input of measure is within a range
    function validInput(inputStartMeasure, inputEndMeasure) {
        var start = true
        var end = true
        if (inputStartMeasure < 1 || inputStartMeasure > inputEndMeasure || inputStartMeasure > newTemp.orgEndMeasure) {
            start = false
        }
        if (inputEndMeasure < 1  || inputEndMeasure < inputStartMeasure || inputEndMeasure > newTemp.orgEndMeasure) {
            end = false
        }
        if (start == false && end == false) {
            return [false, false, "Please select a valid start measure and end measure.\nInput start measure must be between 1 and end measure.\nInput end measure must be between start measure and "+newTemp.orgEndMeasure]
        } else if (start == false) {
            return [false, true, "Please select a valid start measure.\nInput start measure must be between 1 and " + inputEndMeasure]
        } else if (end == false) {
            return [true, false, "Please select a valid end measure. \nInput end measure must be between " + inputStartMeasure+" and "+newTemp.orgEndMeasure]
        } else {
            return [true, true, ""]
        }
    }

    //remove html tag for particular notation
    function removeHtmlTag(text) {
        var newText = ""
        var startTag = false
        for (var i in text) {
            if (text[i] == "<") {
            startTag = true
            } else if (text[i] != ">" && text[i] != "<") {
            if (!startTag) {
                newText += text[i]
            }
            } else if (text[i] == ">") {
            startTag = false
            }
        }
        return newText
    }

    //get note notation by beat
    function getBeatInfo(clef, startMeasure, tempBeat) {
        //all notation in certain beat of certain measure
        var temp=0
        temp=startMeasure==newTemp.orgEndMeasure?division / timeSigDen * 4:0

        curScore.startCmd()
        curScore.selection.selectRange(division / timeSigDen * 4 * (timeSigNum * (startMeasure - 1) + tempBeat - 1), division / timeSigDen * 4 * (timeSigNum * (startMeasure - 1) + tempBeat)+temp, clef-1, clef)
        curScore.endCmd()

        var prevchord = false //if note is between chord or not
        var harmony = 0 //number of chords(more than one note)
        var note = 0 //number of notes
        var rest = 0 //number of rest
        beatText = "" //number of harmony, note, rest
        beatDetailed = "" //detailed of each notation

        var prevTick = false //previous tick
        var n = 0; 
        //if beat empty, return to last tick until having note/rest
        if (curScore.selection.elements.length == 0 || curScore.selection.elements[0].type == Element.CLEF) {
            beatDetailed += "Keep "
            prevTick = true
        }
        while (curScore.selection.elements.length == 0 || curScore.selection.elements[0].type == Element.CLEF) {
            curScore.startCmd()
            curScore.selection.selectRange(division / timeSigDen * 4 * (timeSigNum * (startMeasure - 1) + tempBeat - 1) - division * (1 / 16 + n / 96), division / timeSigDen * 4 * (timeSigNum * (startMeasure - 1) + tempBeat) - division * (1 / 16 + n / 96)+temp, clef - 1, clef)
            curScore.endCmd()
            ++n
        }

        //if selected beat empty, set previous tick as beat notation
        startBeat = prevTick ? division / timeSigDen * 4 * (timeSigNum * (startMeasure - 1) + tempBeat - 1) - division * (1 / 16 + n / 96) : division / timeSigDen * 4 * (timeSigNum * (startMeasure - 1) + tempBeat - 1)
        endBeat = prevTick ? division / timeSigDen * 4 * (timeSigNum * (startMeasure - 1) + tempBeat) - division * (1 / 16 + n / 96) : division / timeSigDen * 4 * (timeSigNum * (startMeasure - 1) + tempBeat)

        //find duration and pitch of tie
        curScore.startCmd()
        curScore.selection.selectRange(division / timeSigDen * 4 * timeSigNum * (startMeasure - 2), division / timeSigDen * 4 * timeSigNum * (startMeasure +1) , clef-1, clef)
        curScore.endCmd()
        for (var i = 0; i < curScore.selection.elements.length; i++) {
            if (curScore.selection.elements[i].type == Element.TIE) {
                tieTickPitch.push(curScore.selection.elements[i].parent.pitch)
                tieTick.push(curScore.selection.elements[i].parent.lastTiedNote.parent.parent.tick)
            }
        }

        //find duration of each note/rest, tick and pitch of tie
        curScore.startCmd()
        curScore.selection.selectRange(startBeat, endBeat+temp, clef - 1, clef)
        curScore.endCmd()
        var noteDuration = []; 
        var prevChord = null
        for (var i = 0; i < curScore.selection.elements.length; i++) {
            if (curScore.selection.elements[i].type === Element.NOTE) {
                var chord = curScore.selection.elements[i].parent;
                if (!prevChord || (prevChord !== chord)) {
                    noteDuration.push(chord);
                }
                prevChord = chord;
            } else if ((curScore.selection.elements[i].type === Element.CHORD) || (curScore.selection.elements[i].type === Element.REST)) {
                noteDuration.push(curScore.selection.elements[i]);
            }
        }

        //set note notation with detailed(as per tick in beat)
        var index = 0 
        var noteDurationIndex = 0

        while (startBeat < endBeat) {
            index++
            var newDynamic = null
            var arpeggio = null
            var articulation = null
            var artType = -1
            var chordCheck=false
            var realHarmony=false
            var tempIndex=index

            nextTick = noteDurationIndex == noteDuration.length ? division / 16 : noteDuration[noteDurationIndex].duration.numerator / noteDuration[noteDurationIndex].duration.denominator * division * 4
            var noteLength = noteDuration[noteDurationIndex].duration.denominator
            var i = 0;

            //select tick within beat
            curScore.startCmd()
            curScore.selection.selectRange(startBeat, (startBeat + nextTick), clef-1, clef)
            curScore.endCmd()

            //if non music score related elements, ignore
            if (curScore.selection.elements.length == 0 || curScore.selection.elements[0] == "VBox") {
                startBeat += nextTick
                continue;
            }
            //music notation of each tick between the beat
             for (i; i < curScore.selection.elements.length; i++) {

                //indicate start of slur or end of slur
                if (curScore.selection.elements[i].type == Element.SLUR) //if slur
                {
                    //right
                    if(clef==1){
                        if(!rightStartSlur){
                            beatDetailed += "Start of Slur, "
                        }else{
                            beatDetailed +=", End of Slur"
                        }
                        rightStartSlur=!rightStartSlur
                    }
                    if(clef==2){
                        if(!leftStartSlur){
                            beatDetailed += "Start of Slur, "
                        }else{
                            beatDetailed +=", End of Slur"
                        }
                        leftStartSlur=!leftStartSlur
                    }
                }

                //detailed notation for harmony, note and rest
                if (curScore.selection.elements[i].type == Element.HARMONY) 
                {
                    beatDetailed = beatDetailed + index + ". "
                    if (arpeggio == startBeat) {
                        beatDetailed += "areggio with "
                    }
                    if (newDynamic != null) {
                        beatDetailed += ("Start "+newDynamic)
                    }
                    harmony++;
                    beatDetailed = beatDetailed + " harmony of "
                    var noteStart = false
                    for (var k = ++i; k < curScore.selection.elements.length; k++) {
                        if (k == curScore.selection.elements.length - 1 && curScore.selection.elements[k].type == Element.NOTE) {
                            if (startBeat == tieTick[tieTickIndex] && curScore.selection.elements[k].pitch == tieTickPitch[tieTickIndex]) {
                                beatDetailed += " tie "
                                tieTickIndex++
                            }
                            beatDetailed += noteLength + "th " + noteName[curScore.selection.elements[k].tpc-6] + (Math.floor(curScore.selection.elements[k].pitch / 12) - 1) + " note "
                            i = k
                            if (articulation == startBeat) {
                            beatDetailed += "with " + artType
                            }
                            break;
                        }
                        if (noteStart && curScore.selection.elements[k].type != Element.NOTE) {
                            i = k
                            if (articulation == startBeat) {
                            beatDetailed += "with " + artType
                            }
                            break;
                        }
                        else if (curScore.selection.elements[k].type == Element.NOTE) {

                            if (startBeat == tieTick[tieTickIndex] && curScore.selection.elements[k].pitch == tieTickPitch[tieTickIndex]) {
                            beatDetailed += " tie "
                            tieTickIndex++
                            }
                            noteStart = true
                            beatDetailed += noteLength + "th " + noteName[curScore.selection.elements[k].tpc -6] + (Math.floor(curScore.selection.elements[k].pitch / 12) - 1) + " note "
                            if (articulation == startBeat) {
                            beatDetailed += "with " + artType
                            }
                            i = k

                        }
                    }
                }else if (curScore.selection.elements[i].type == Element.NOTE){
                    note++
                    if(!chordCheck){
                        beatDetailed += index + ". "
                        tempIndex=index
                        chordCheck=true
                    }else{
                        if(tempIndex==index){
                            if(realHarmony){
                                harmony++
                                note--
                            }
                            realHarmony=true
                            note--
                        }else{
                            beatDetailed += index + ". "
                        }
                    }
                    
                    if (newDynamic != null) {
                        beatDetailed += (newDynamic + " Start ")
                    }
                    if (startBeat == tieTick[tieTickIndex] && curScore.selection.elements[i].pitch == tieTickPitch[tieTickIndex]) {
                        beatDetailed += " tie "
                        tieTickIndex++
                    }
                    beatDetailed+=noteLength + "th " + noteName[curScore.selection.elements[i].tpc -6] + (Math.floor(curScore.selection.elements[i].pitch / 12) - 1) + " note "
                    if (articulation == startBeat) {
                        beatDetailed += "with " + artType
                    }
                }else if (curScore.selection.elements[i].type == Element.REST) 
                {
                    if (newDynamic != null) {
                        beatDetailed += (newDynamic + " Start ")
                    }
                    beatDetailed = beatDetailed + index + ". " + noteLength + "th rest "
                    rest++
                }

                //other music notation 
                if (curScore.selection.elements[i].name == "StaffText") {
                    beatDetailed += removeHtmlTag(curScore.selection.elements[i].text)
                }
                if (curScore.selection.elements[i].name == "Dynamic") {
                    newDynamic = removeHtmlTag(curScore.selection.elements[i].text)
                    newDynamic = newDynamic.substr(7, newDynamic.length)
                }
                if (curScore.selection.elements[i].name == "Arpeggio") {
                    arpeggio = curScore.selection.elements[i].parent.parent.tick //at tick
                    
                }
                if (curScore.selection.elements[i].name == "Articulation") {
                    articulation = curScore.selection.elements[i].parent.parent.tick //at tick
                    artType = curScore.selection.elements[i].symbol
                }
            }

            if(tieTickIndex+1==tieTickPitch.length){
                tieTickIndex=0
                tieTickPitch=[]
                tieTick=[]
            }
            
            //next tick within beat
            startBeat += nextTick
            noteDurationIndex++
            beatDetailed += "\n"
        }

        //summary of beat
        if (harmony > 0) {
            beatText = beatText + harmony + " harmony "
        }
        if (note > 0) {
            beatText = beatText + note + " note "
        }
        if (rest > 0) {
            beatText = beatText + rest + " rest "
        }
        beatText+=", details are\n"
    }

    //get beat value of certain measure
    function getBeatValue(beatValue) {
        if (beatValue % timeSigNum == 0) {
            return timeSigNum
        } else{
            return beatValue % timeSigNum
        }
    }

    //return whether the score has content
    function getScoreValid(){
        cmd("select-all")
        for(var i in curScore.selection.elements){
           if(curScore.selection.elements[i].type!=Element.REST){
            return true
           }
        }
        return false
    }

     Component.onCompleted: {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Specific bar and notation selection")
            thumbnailName = "specific.png"
            allowScreenReader=false
            onScreenReader=false
        }else if(mscoreMajorVersion == 3){
            allowScreenReader=true
            onScreenReader=true
        }else {
            mainWindow.visible=false
        }
    }

    onRun: {
        if(!getScoreValid()){
            homeWindow.visible=false
            measureWrongMsg.open()
        }else{
            maxMeasure= curScore.nmeasures
            orgScoreName= curScore.scoreName
            pluginscope.c = curScore.newCursor();
            pluginscope.c.rewind(Cursor.SCORE_START);
            pluginscope.c.nextMeasure();
            timeSigDen=c.measure.timesigActual.denominator
            timeSigNum=c.measure.timesigActual.numerator

            getBeatInfo(1, 1, 1)
            tempRightNotes=beatText+beatDetailed
            getBeatInfo(2, 1, 1)
            tempLeftNotes=beatText+beatDetailed

            cmd("select-all")
            for (var i in curScore.selection.elements) {
                if (curScore.selection.elements[i].type == Element.TEMPO_TEXT) {
                    defaultTempo=curScore.selection.elements[i].tempo*60
                    curTempo=defaultTempo
                    break;
                }
            }
            curScore.selection.clear()
        }





    }

    //Home Page
    Window {
        modality:Qt.WindowModal
        id: homeWindow
        minimumHeight: defaultHeight
        minimumWidth: defaultWidth
        maximumHeight:screenHeight
        maximumWidth:screenWidth
        width: defaultWidth
        height: defaultHeight
        x: (screenWidth - homeWindow.width) / 2
        y: (screenHeight - homeWindow.height) / 2
        visible: true
        title: "Specific Measure and Notation Selection - Home Page"
        Label {
            id:homePageLabel
            text:"Home Page"
            Accessible.description:"In this page you can learn more about this plugin, start the plugin or quit the plugin."
            anchors.horizontalCenter: parent.horizontalCenter
            Accessible.readOnly:true
            Accessible.name: text
            Accessible.role:Accessible.StaticText
            font.pixelSize:50
            font.bold:true
        }
        Row {
            visible:allowScreenReader
            anchors.right: parent.right
            anchors.rightMargin:5            
            Switch {
                id: screenReaderBtn1
                checked:onScreenReader
                Accessible.name: "Screen Reader"
                Accessible.description: screenReaderBtn1.checked?"To indicate screen Reader as on. Click to turn off.":"To indicate screen Reader as off. Click to turn on."
                Accessible.role:Accessible.Button
                Accessible.readOnly:true
                onClicked:onScreenReader=screenReaderBtn1.checked
                Accessible.onPressAction:{
                    screenReaderBtn1.checked=!screenReaderBtn1.checked
                    onScreenReader=screenReaderBtn1.checked
                }

            }
            Text {
                text: screenReaderBtn1.checked? "Screen Reader ON" :"Screen Reader OFF"
                font.pixelSize:20
                font.bold: true
                color: screenReaderBtn1.checked?"green":"red"
            }
        }      
        GridLayout {
            id:homeBtns
            rowSpacing:10
            anchors.horizontalCenter: homePageLabel.horizontalCenter
            anchors.top:homePageLabel.bottom
            anchors.topMargin: 80
            anchors.margins:20
            anchors.fill:parent
            flow: GridLayout.TopToBottom
            Button {
                id:infoBtn
                text: "How to Use"
                font.bold: true
                font.pixelSize: 110
                Layout.fillWidth: true
                Layout.fillHeight:true
                Accessible.focusable:true
                Accessible.focused:true
                Accessible.name: infoBtn.text
                Accessible.role: Accessible.Button
                Accessible.description: "Press to learn how to use the plugin, new users are recommend to read this before starting the plugin"
                Accessible.onPressAction: {
                    onScreenReader?infoDialog.open():""
                    
                }
                onClicked: {
                    onScreenReader?"":infoDialog.open()
                }
            }
            Button {
                id:startBtn
                text:"Start"
                font.bold: true
                font.pixelSize: 110
                Layout.fillWidth: true
                Layout.fillHeight:true
                Accessible.focusable:true
                Accessible.focused:true
                Accessible.name: startBtn.text
                Accessible.role: Accessible.Button
                Accessible.description: "Press to start the plugin"
                Accessible.onPressAction: {
                    if(!getScoreValid()){
                        measureWrongMsg.text = "Current score is empty. Please open a new score."
                        measureWongMsg.x=(mainWindow.width - measureWongMsg.width) / 2
                        measureWongMsg.y=(mainWindow.height - measureWongMsg.height) / 2
                        measureWrongMsg.open()
                    }else{
                        if(onScreenReader){
                            startWindow.visible=true
                            homeWindow.visible=false
                        }
                    }
                }
                onClicked: {
                    if(!getScoreValid()){
                        measureWrongMsg.text = "Current score is empty. Please open a new score."
                        measureWrongMsg.open()
                    }else{
                        if(!onScreenReader){
                            startWindow.visible=true
                            homeWindow.visible=false
                        }
                    }
                    
                }
            }
            Button {
                id:quitBtn
                text: "Quit"
                font.bold: true
                font.pixelSize: 110
                Layout.fillWidth: true
                Layout.fillHeight:true
                Accessible.focusable:true
                Accessible.focused:true
                Accessible.name: quitBtn.text
                Accessible.description: "Press to quit the plugin"
                Accessible.onPressAction: {
                    if(onScreenReader){
                        if (curScore.scoreName==tempScoreName)
                        {
                            newTemp.create=false
                            closeScore(curScore)
                        }
                        homeWindow.close()
                    }
                }
                onClicked: {
                    if(!onScreenReader){
                        if (curScore.scoreName==tempScoreName)
                        {
                            newTemp.create=false
                            closeScore(curScore)
                        }
                        homeWindow.close()
                    }
                }
                
            }
        }
        Dialog {
            visible:false
            id:infoDialog
            
            Text {
                id:infolearnText
                font.pixelSize: 13
                wrapMode:Text.WordWrap
                Accessible.role:Accessible.StaticText
                Accessible.multiLine:true
                Accessible.description:infolearnText.text
                text: "This plugin aims to help visually impaired person to read music score in MuseScore.

Functions included:
1. Select a range of measure or bar 
2. Set tempo
3. Set staff(current version only provide 2 staff)
4. View music notation beat by beat

To start the plugin, open a non-empty score. 
Also, user must set screen reader on or off in the plugin to indicate as using screen reader or not. 
If screen reader is using but set as off, screen reader will not provide feedback of current action.

In the interface, user only require to input and navigate the interface using arrow keys.                
Please refer to the corresponding screen reader document for detailed commands.

For detailed description, please read the README.pdf file inside the folder."
            }
        }    
    }

    //Start page
    Window {
        Accessible.role:Accessible.Dialog
        visible: false
        id:startWindow
        minimumHeight: defaultHeight
        minimumWidth: defaultWidth
        maximumHeight:screenHeight
        maximumWidth:screenWidth
        width: defaultWidth
        height: defaultHeight
        x: (screenWidth - homeWindow.width) / 2
        y: (screenHeight - homeWindow.height) / 2
        title: "Specific Measure and Notation Selection - Start Page"
        Button {
            anchors.leftMargin:20           
            id:returnHomeText
            width: 150
            text:"< Home Page"
            anchors.left:parent.left
            anchors.top: parent.top
            anchors.topMargin:10
            Accessible.focusable:true
            Accessible.focused:true
            Accessible.name: returnHomeText.text
            Accessible.role: Accessible.Button
            Accessible.description: "Press to return to home page"
            font.pixelSize: 20
            font.bold:true
            Accessible.onPressAction:function(){
            if(onScreenReader){homeWindow.visible=true
            startWindow.visible=false}
            }
            onClicked:{
                if(!onScreenReader){homeWindow.visible=true
            startWindow.visible=false}
            }
        }

        Label {
            id:startPageLabel
            text:"Start Page"
            Accessible.description:"Current score is "+orgScoreName+".  You can select a range of measure, set tempo, set clef and view note notation in this page."
            anchors.horizontalCenter: parent.horizontalCenter
            Accessible.readOnly:true
            Accessible.name: text
            Accessible.role:Accessible.StaticText
            font.pixelSize:50
            font.bold:true
        }
        Row {
            anchors.topMargin:20
            visible:allowScreenReader
            anchors.right: parent.right
            anchors.rightMargin:10  
            Switch {
                id: screenReaderBtn2
                checked:onScreenReader
                Accessible.name: "Screen Reader"
                Accessible.description: screenReaderBtn2.checked?"Screen Reader is on":"Screen Reader is off"
                Accessible.role:Accessible.Button
                Accessible.readOnly:true
                onClicked:onScreenReader=screenReaderBtn2.checked
                Accessible.onPressAction:{
                    screenReaderBtn2.checked=!screenReaderBtn2.checked
                    onScreenReader=screenReaderBtn2.checked
                }
            }
            Text {
                text: screenReaderBtn2.checked? "Screen Reader ON" :"Screen Reader OFF"
                font.pixelSize:20
                font.bold: true
                color: screenReaderBtn2.checked?"green":"red"
            }
        }
        GridLayout{
            Layout.fillWidth:true
            anchors.top:startPageLabel.bottom
            flow: GridLayout.TopToBottom
            anchors.topMargin: 80
            anchors.fill: parent
            anchors.margins:20
            GridLayout{
                id:startBtns
                anchors.topMargin: 80
                flow: GridLayout.TopToBottom
                Layout.fillWidth: true
                height: startWindow.height*0.6
                Row {
                    Text {
                        text: "Start Measure(current "+startMeasure+", max "+maxMeasure+"): "
                        Accessible.description: "Set Start Measure, current start measure is"+startMeasure+", select a value between 1 to "+maxMeasure
                        font.pixelSize:35
                        font.bold:true
                    }
                    TextField {
                        id:inputStartMeasure
                        focus:true
                        Accessible.focusable:true
                        Accessible.focused:true
                        Accessible.role:Accessible.EditableText
                        Accessible.description: "Select a value between 1 to "+endMeasure+". Only numbers can be input."
                        Accessible.editable:true
                        validator: RegExpValidator { regExp: /^[0-9]*$/ } 
                    }
                }
                Row {
                    Text {
                        text: "End Measure(current "+endMeasure+", max "+maxMeasure+"): "
                        Accessible.description: "Set End Measure, current end measure is "+endMeasure+", select a value between 1 to "+maxMeasure
                        font.pixelSize:35
                        font.bold:true
                    }
                    TextField {
                        id:inputEndMeasure
                        Accessible.focusable:true
                        Accessible.focused:true
                        Accessible.role:Accessible.EditableText
                        Accessible.description: "Select a value between "+startMeasure+" to "+maxMeasure+". Only numbers can be input."
                        Accessible.editable:true
                        validator: RegExpValidator { regExp: /^[0-9]*$/ } }
                }
                Row {
                    Text {
                        text: "Tempo(current "+curTempo+", default "+defaultTempo+"): "
                        Accessible.description: "Set tempo, current tempo is "+curTempo+"and default is "+defaultTempo
                        font.pixelSize:35
                        font.bold:true
                    }
                    TextField {
                        id:inputTempo
                        Accessible.focusable:true
                        Accessible.focused:true
                        Accessible.role:Accessible.EditableText
                        Accessible.description: "Enter a tempo, current is"+curTempo+" and default is "+defaultTempo+". Only numbers can be input."
                        Accessible.editable:true
                        validator: RegExpValidator { regExp: /^[0-9]*$/ }
                    }
                }
                Row {
                    Layout.fillWidth: true
                    Layout.fillHeight:true
                    spacing: 10
                    Text {
                        text: "Staff:  "
                        Accessible.description:"Set both staff, top staff or bottom staff, current is "+getClefText()
                        font.pixelSize:35
                        font.bold:true
                    }
                    Button {
                        checked:curClef==-1?true:false
                        highlighted:curClef==-1?true:false
                        id: bothClefBtn
                        text: "Both Staff"
                        font.bold: true
                        font.pixelSize: 30
                        Layout.fillWidth: true
                        Layout.fillHeight:true
                            Accessible.focusable:true
                            Accessible.focused:true
                            Accessible.role:Accessible.Button
                            Accessible.description:"Set both staff"
                            Accessible.onPressAction: {
                            onScreenReader?curClef=-1:""
                            }
                            onClicked: {
                                onScreenReader?"":curClef=-1
                            }
                    }

                    Button {
                        text: "Top Staff"
                        id: rightClefBtn
                        font.bold: true
                        font.pixelSize: 30
                        Layout.fillWidth: true
                        Layout.fillHeight:true                                
                        checked:curClef==0?true:false
                            highlighted:curClef==0?true:false
                            Accessible.focusable:true
                            Accessible.focused:true
                            Accessible.role:Accessible.Button
                            Accessible.description:"Set top staff"
                            Accessible.onPressAction: {
                            onScreenReader?curClef=0:""
                            }
                            onClicked: {
                                onScreenReader?"":curClef=0
                            }
                    }

                    Button {
                        text: "Bottom Staff"
                        id: leftClefBtn
                        checked:curClef==1?true:false
                        highlighted:curClef==1?true:false
                        font.bold: true
                        font.pixelSize: 30
                        Layout.fillWidth: true
                        Layout.fillHeight:true                                
                        Accessible.focusable:true
                        Accessible.focused:true
                        Accessible.checkable:true
                        Accessible.role:Accessible.Button
                        Accessible.description:"Set bottom staff"
                        Accessible.onPressAction: {
                        onScreenReader?curClef=1:""
                        }
                        onClicked: {
                            onScreenReader?"":curClef=1
                        }
                    }
                }
            }
            GridLayout {
                anchors.top:startBtns.bottom
                id:playBtns
                columnSpacing:10
                columns:3
                Layout.fillWidth: true
                height: startWindow.height*0.3
                Button {
                    id:resetBtn
                    text:"Reset"
                    font.bold: true
                    font.pixelSize: 40
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Accessible.focusable:true
                    Accessible.focused:true
                    Accessible.role:Accessible.Button
                    Accessible.name:playBtn.text
                    Accessible.description:"Press to reset to default "
                    Accessible.onPressAction: {
                        if(onScreenReader){
                            if (curScore.scoreName==tempScoreName)
                            {
                                newTemp.create=false
                                closeScore(curScore)
                            }
                            startMeasure=1
                            endMeasure=newTemp.orgEndMeasure
                            curClef=-1
                            curTempo=defaultTempo
                            inputEndMeasure.text=""
                            inputStartMeasure.text=""
                            inputTempo.text==""
                            }
                    }
                    onClicked: {
                        if(!onScreenReader){
                            if (curScore.scoreName==tempScoreName)
                            {
                                newTemp.create=false
                                closeScore(curScore)
                            }
                            startMeasure=1
                            endMeasure=newTemp.orgEndMeasure
                            curClef=-1
                            curTempo=defaultTempo

                            inputEndMeasure.text=""
                            inputStartMeasure.text=""
                            inputTempo.text==""

                            }
                    }
                }
                Button {
                    property var tempStart: tempStart=inputStartMeasure.text=="" ?startMeasure:inputStartMeasure.text
                    property var tempEnd: tempEnd=inputEndMeasure.text=="" ?endMeasure:inputEndMeasure.text
                    id:playBtn
                    text: "Set"
                    font.bold: true
                    font.pixelSize: 40
                    Layout.fillWidth: true
                    Layout.fillHeight:true
                    Accessible.focusable:true
                    Accessible.focused:true
                    Accessible.role:Accessible.Button
                    Accessible.name:playBtn.text
                    Accessible.description:"Press to set measure from "+inputStartMeasure.text+" to "+inputEndMeasure.text+", with "+getClefText()+" and tempo "+inputTempo.text+".   After setting, press the space button to play or stop."
                    Accessible.onPressAction: {
                        if(onScreenReader){
                            tempStart=inputStartMeasure.text=="" ?startMeasure:inputStartMeasure.text
                            tempEnd=inputEndMeasure.text=="" ?endMeasure:inputEndMeasure.text

                            var validValues=validInput(tempStart, tempEnd)
                            measureWrongMsg.text = validValues[2]
                            //validInput
                            if (validValues[0]==false || validValues[1]==false)
                            {
                                inputStartMeasure.text=validValues[0]==false?"":inputStartMeasure.text
                                inputEndMeasure.text=validValues[1]==false?"":inputEndMeasure.text
                                measureWrongMsg.open()


                            }else {
                                if (tempStart!=startMeasure || tempEnd!=endMeasure)
                                {
                                    if (curScore.scoreName==tempScoreName)
                                    {
                                        newTemp.create=false
                                        closeScore(curScore)
                                    }
                                    inputEndMeasure.text=""
                                    inputStartMeasure.text=""
                                    curTempo=inputTempo.text==""?curTempo:parseInt(inputTempo.text)
                                    inputTempo.text=""
                                    startMeasure=tempStart
                                    endMeasure=tempEnd
                                    playMeasure()
                                    setClef()
                                    startMeasure=tempStart
                                    endMeasure=tempEnd
                                }else { //same input and in temp score
                                    var tempo=inputTempo.text==""? curTempo: parseInt(inputTempo.text)
                                    if (curScore.scoreName==tempScoreName)
                                    {
                                        newTemp.create=true
                                        if (curTempo!=tempo)
                                        {
                                            curTempo=tempo
                                            changeMeasureTempo()
                                            inputTempo.text=""
                                        }
                                        setClef()
                                    }
                                }
                            }
                        }
                    }
                    onClicked:{
                        if(!onScreenReader){
                            tempStart=inputStartMeasure.text=="" ?startMeasure:inputStartMeasure.text
                            tempEnd=inputEndMeasure.text=="" ?endMeasure:inputEndMeasure.text

                            var validValues=validInput(tempStart, tempEnd)
                            measureWrongMsg.text = validValues[2]
                            //validInput
                            if (validValues[0]==false || validValues[1]==false)
                            {
                                inputStartMeasure.text=validValues[0]==false?"":inputStartMeasure.text
                                inputEndMeasure.text=validValues[1]==false?"":inputEndMeasure.text
                                measureWrongMsg.open()


                            }else {
                                if (tempStart!=startMeasure || tempEnd!=endMeasure)
                                {
                                    if (curScore.scoreName==tempScoreName)
                                    {
                                        newTemp.create=false
                                        closeScore(curScore)
                                    }
                                    inputEndMeasure.text=""
                                    inputStartMeasure.text=""
                                    curTempo=inputTempo.text==""?curTempo:parseInt(inputTempo.text)
                                    inputTempo.text=""
                                    startMeasure=tempStart
                                    endMeasure=tempEnd
                                    playMeasure()
                                    setClef()
                                    startMeasure=tempStart
                                    endMeasure=tempEnd
                                }else { //same input and in temp score
                                    var tempo=inputTempo.text==""? curTempo: parseInt(inputTempo.text)
                                    if (curScore.scoreName==tempScoreName)
                                    {
                                        newTemp.create=true
                                        if (curTempo!=tempo)
                                        {
                                            curTempo=tempo
                                            changeMeasureTempo()
                                            inputTempo.text=""
                                        }
                                        setClef()
                                    }
                                }
                            }
                        }
                    }
                }
                Button {
                    id:viewBeatBtn
                    text: "View detailed music<br>notation by beat"
                    font.bold: true
                    font.pixelSize: 30
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Accessible.focusable:true
                    Accessible.focused:true
                    Accessible.role:Accessible.Button
                    Accessible.description:"Press to view detailed music notation by beat 1 of measure "+inputStartMeasure.text
                    Accessible.name:viewBeatBtn.text
                    Accessible.onPressAction: {
                        if(onScreenReader){
                            if (curScore.scoreName==tempScoreName)
                            {
                                newTemp.create=false
                                closeScore(curScore)
                            }

                            var tempStart
                            var tempEnd
                            if (inputStartMeasure.text=="")
                            {
                                tempStart=startMeasure

                            }else {
                            tempStart=inputStartMeasure.text
                            }
                            tempEnd=newTemp.orgEndMeasure //end measure do not affect
                            var validValues=validInput(tempStart, tempEnd)
                            measureWrongMsg.text = validValues[2]

                            if (validValues[0]==false || validValues[1]==false)
                            {
                            measureWrongMsg.open()
                            inputStartMeasure.text=validValues[0]==false?"":inputStartMeasure.text
                            inputEndMeasure.text=validValues[1]==false?"":inputEndMeasure.text

                            }else {
                                startMeasure=tempStart
                                endMeasure=endMeasure
                                getBeatInfo(1, startMeasure, 1)
                                tempRightNotes=beatText+beatDetailed
                                getBeatInfo(2, startMeasure, 1)
                                tempLeftNotes=beatText+beatDetailed
                                detailedLeftBeatTextArea.text=tempLeftNotes
                                detailedRightBeatTextArea.text=tempRightNotes
                                tempBeat=(startMeasure-1)*4+1
                                inputEndMeasure.text=""
                                inputStartMeasure.text=""
                                inputTempo.text==""
                                beatWindow.visible=true
                                startWindow.visible=false
                            }
                        }
                    }
                    onClicked:{
                        if(!onScreenReader){
                            if (curScore.scoreName==tempScoreName)
                            {
                                newTemp.create=false
                                closeScore(curScore)
                            }

                            var tempStart
                            var tempEnd
                            if (inputStartMeasure.text=="")
                            {
                                tempStart=startMeasure

                            }else {
                            tempStart=inputStartMeasure.text
                            }
                            tempEnd=newTemp.orgEndMeasure //end measure do not affect
                            var validValues=validInput(tempStart, tempEnd)
                            measureWrongMsg.text = validValues[2]

                            if (validValues[0]==false || validValues[1]==false)
                            {
                            inputStartMeasure.text=validValues[0]==false?"":inputStartMeasure.text
                            inputEndMeasure.text=validValues[1]==false?"":inputEndMeasure.text

                            measureWrongMsg.open()

                            }else {
                                startMeasure=tempStart
                                endMeasure=endMeasure
                                getBeatInfo(1, startMeasure, 1)
                                tempRightNotes=beatText+beatDetailed
                                getBeatInfo(2, startMeasure, 1)
                                tempLeftNotes=beatText+beatDetailed
                                detailedLeftBeatTextArea.text=tempLeftNotes
                                detailedRightBeatTextArea.text=tempRightNotes
                                tempBeat=(startMeasure-1)*4+1
                                inputEndMeasure.text=""
                                inputStartMeasure.text=""
                                inputTempo.text==""

                                beatWindow.visible=true
                                startWindow.visible=false
                            }
                        }
                    }
                }
            }            
        }                
        
    }

    //Notation page
    Window {
        visible:false
        id: beatWindow
        minimumHeight: defaultHeight
        minimumWidth: defaultWidth
        maximumHeight:screenHeight
        maximumWidth:screenWidth
        width: defaultWidth
        height: defaultHeight
        x: (screenWidth - homeWindow.width) / 2
        y: (screenHeight - homeWindow.height) / 2
        title: "Specific Measure and Notation Selection - Notation Page"
        RowLayout{
                x:10
                y:10
            Button {
                id:returnStart
                anchors.top:parent.top
                text:"< Start Page"
                font.bold:true
                Accessible.focusable:true
                Accessible.focused:true
                Accessible.name: returnStart.text
                Accessible.role: Accessible.Button
                Accessible.description: "Press to return to start page"
                font.pixelSize: 20
                Accessible.onPressAction:{
                    if(onScreenReader){
                        startWindow.visible=true
                        beatWindow.visible=false

                    }
                }
                onClicked:{
                    if(!onScreenReader){
                        startWindow.visible=true
                        beatWindow.visible=false

                    }
                }
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: beatWindow.width-380
                Layout.preferredHeight: 60

                anchors.leftMargin: 90
                id:notationPageLabel
                text:"Note Notation: Measure "+Math.ceil(tempBeat/timeSigNum)+" Beat "+getBeatValue(tempBeat)
                Accessible.description:"Current score is "+orgScoreName+".  View detailed of beat "+getBeatValue(tempBeat)+" from measure "+Math.ceil(tempBeat/timeSigNum)
                anchors.top: parent.top
                Accessible.readOnly:true
                Accessible.name: text
                Accessible.role:Accessible.StaticText
                font.pixelSize:28
                font.bold:true
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 20
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 270
                Layout.preferredHeight: 60
                visible:allowScreenReader
                Switch {
                    id: screenReaderBtn3
                    checked:onScreenReader
                    Accessible.name: "Screen Reader"
                    Accessible.description: screenReaderBtn3.checked?"Screen Reader is on":"Screen Reader is off"
                    Accessible.role:Accessible.Button
                    Accessible.readOnly:true
                    onClicked:onScreenReader=screenReaderBtn3.checked
                    Accessible.onPressAction:{
                        if(onScreenReader){
                            screenReaderBtn3.checked=!screenReaderBtn3.checked
                            onScreenReader=screenReaderBtn3.checked
                        }
                    }
                }
                Text {
                    text: screenReaderBtn3.checked? "Screen Reader ON" :"Screen Reader OFF"
                    font.pixelSize:18
                    font.bold: true
                    color: screenReaderBtn3.checked?"green":"red"
                }
            }
        }

        GridLayout{
            id:notationGrid
            flow:GridLayout.TopToBottom
            anchors.topMargin: 60
            anchors.fill:parent
            anchors.margins:10
            Text {
                id: timeSigText
                text:"Time Signature: "+timeSigDen+" "+timeSigNum+"\tKeySignature: "+keySig[curScore.keysig+7]
                Accessible.description: "Time Signature: "+timeSigDen+" "+timeSigNum+"\tKeySignature: "+keySig[curScore.keysig+7]
                font.pixelSize:20
                font.bold:true
            }
            ColumnLayout {
                RowLayout {
                    Text{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: beatWindow.width*0.5-10
                        Layout.preferredHeight: 20
                        text: "Detailed Top Staff:"
                        Accessible.focusable:true
                        Accessible.focused:true
                        Accessible.description:"Detailed Top Staff. Go down to read detailed."
                        font.pixelSize: 20
                        font.bold:true
                    }                    
                    Text{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: beatWindow.width*0.5-10
                        Layout.preferredHeight: 20
                        text: "Detailed Bottom Staff:"
                        Accessible.focusable:true
                        Accessible.focused:true
                        Accessible.description:"Detailed Bottom Staff. Go down to read detailed."
                        font.pixelSize: 20
                        font.bold:true
                     }
                }
                RowLayout {
                    spacing:20
                    Rectangle{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: beatWindow.width*0.5-10
                        Layout.preferredHeight: 350
                        Text{
                            id:detailedRightBeatTextArea
                            wrapMode: Text.WrapAnywhere
                            anchors.fill:parent
                            Accessible.role:Accessible.StaticText
                            Accessible.multiLine:true
                            Accessible.focusable:true
                            Accessible.focused:true
                            Accessible.description:detailedRightBeatTextArea.text

                            font.pixelSize: 30
                        }
                    }
                    Rectangle{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: beatWindow.width*0.5-10
                        Layout.preferredHeight: 350
                        Text{
                            id:detailedLeftBeatTextArea
                            wrapMode: Text.WrapAnywhere
                            anchors.fill:parent
                            Accessible.role:Accessible.StaticText
                            Accessible.multiLine:true
                            Accessible.focusable:true
                            Accessible.focused:true
                            Accessible.description:detailedLeftBeatTextArea.text
                            font.pixelSize: 30
                        }
                    }
                }
                RowLayout {
                    Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 30
                        id:prevBeat
                        text: "Previous Beat"
                        font.bold:true
                        font.pixelSize:22
                        Accessible.focusable:true
                        Accessible.focused:true
                        Accessible.role:Accessible.Button
                        Accessible.name:prevBeat.text
                        Accessible.description:"Press to know the previous beat, current is "+getBeatValue(tempBeat)+" from measure "+Math.ceil(tempBeat/timeSigNum), "max "+timeSigNum+" beats and measure "+maxMeasure
                        Accessible.onPressAction: {
                            if(onScreenReader){
                                if ((tempBeat)>1)
                                {
                                    tempBeat--
                                    // 1: right hand/2:left hand(1, 2)
                                    getBeatInfo(1, Math.ceil(tempBeat/timeSigNum), getBeatValue(tempBeat))
                                    tempRightNotes=beatText+beatDetailed
                                    getBeatInfo(2, Math.ceil(tempBeat/timeSigNum), getBeatValue(tempBeat))
                                    tempLeftNotes=beatText+beatDetailed
                                }else {
                                    measureWrongMsg.text="There is no previous beat!"
                                    measureWrongMsg.open()
                                }
                            }
                        }
                        onClicked:{
                            if(!onScreenReader){
                                if ((tempBeat)>1)
                                {
                                    tempBeat--
                                    // 1: right hand/2:left hand(1, 2)
                                    getBeatInfo(1, Math.ceil(tempBeat/timeSigNum), getBeatValue(tempBeat))
                                    detailedRightBeatTextArea.text=beatText+beatDetailed
                                    getBeatInfo(2, Math.ceil(tempBeat/timeSigNum), getBeatValue(tempBeat))
                                    detailedLeftBeatTextArea.text=beatText+beatDetailed
                                }else {
                                measureWrongMsg.text="There is no previous beat!"
                                measureWrongMsg.open()
                                }
                            }

                        }
                    }
                    Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 30
                        id:nextBeat
                        text: "Next Beat"
                        font.bold:true
                        font.pixelSize:22
                        Accessible.focusable:true
                        Accessible.focused:true
                        Accessible.role:Accessible.Button
                        Accessible.name:nextBeat.text
                        Accessible.description:"Press to know the next beat, current is "+getBeatValue(tempBeat)+" from measure "+Math.ceil(tempBeat/timeSigNum), "max "+timeSigNum+" beats and measure "+maxMeasure
                        Accessible.onPressAction: {
                            if(onScreenReader){
                                if ((tempBeat)<=timeSigNum*maxMeasure-1)
                                {
                                tempBeat++
                                // 1: right hand/2:left hand(1, 2)
                                    getBeatInfo(1, Math.ceil(tempBeat/timeSigNum), getBeatValue(tempBeat))
                                    detailedRightBeatTextArea.text=beatText+beatDetailed
                                    getBeatInfo(2, Math.ceil(tempBeat/timeSigNum), getBeatValue(tempBeat))
                                    detailedLeftBeatTextArea.text=beatText+beatDetailed
                                }else {
                                    measureWrongMsg.text="There is no next beat!"
                                    measureWrongMsg.open()
                                }
                            }                        
                        }
                        onClicked:{
                            if(!onScreenReader){
                                if ((tempBeat)<=timeSigNum*maxMeasure-1)
                                {
                                tempBeat++
                                // 1: right hand/2:left hand(1, 2)
                                    getBeatInfo(1, Math.ceil(tempBeat/timeSigNum), getBeatValue(tempBeat))
                                    detailedRightBeatTextArea.text=beatText+beatDetailed
                                    getBeatInfo(2, Math.ceil(tempBeat/timeSigNum), getBeatValue(tempBeat))
                                    detailedLeftBeatTextArea.text=beatText+beatDetailed
                                }else {
                                    measureWrongMsg.text="There is no next beat!"
                                    measureWrongMsg.open()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    //Wrong Message Dialog
    MessageDialog {
        id:measureWrongMsg
        height:100
        width: 300
        title:"Message"
        text:"Current score is empty. Please open a new score."
        Accessible.focusable:true
        Accessible.focused:true
        Accessible.role:Accessible.AlertMessage
        Accessible.name:measureWrongMsg.title
        Accessible.description:measureWrongMsg.text

    }
}
