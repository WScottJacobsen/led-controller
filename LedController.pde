import java.util.Scanner;
import processing.serial.*;
import processing.sound.*;
import java.awt.AWTException;
import java.awt.Dimension;
import java.awt.Robot;
import java.awt.Toolkit;
import java.awt.image.BufferedImage;
import java.io.IOException;

ArrayList<ArrayList<InputElement>> elements; //Holds all buttons and sliders, each ArrayList<InputElement> represents a "page"
int numPages = 4; //Total number of pages
final int MAIN_MENU = 0, EFFECTS = 1, EFFECT_SETTINGS = 2, LED_SETTINGS = 3;
int pageNumber = MAIN_MENU; //Page that is visible
Style INPUT_STYLE;
float titleHeight = 50.0;
Strip strip = new Strip(288); //Initialize strip with 288 led
ArrayList<Integer> effects = new ArrayList<Integer>();
int delay, lastUpdate;
float blinkLength, blinkDelay, position, solidColor, rbFreq, pulseDelay, usaFreq, speed, breatheFreq, maxBrightness, vol;
Serial port;
Effect effectHandler = new Effect(strip);
Amplitude amp;
AudioIn in;

//TODO: Music Reactive doesnt work, faster video responsive, pulse start w/o changing setting

//Initialize variables and create and align InputElements
void setup() {
    size(800, 800);
    rectMode(CENTER); //Draw rectangles from the center point
    INPUT_STYLE = new Style(#000000, #FFFFFF, #FFFFFF, #000000, #000000, 1, createFont("mononoki.ttf", 16, true), 16); //Black text on white background with black outline, inverted colors when hovered, mononoki font at 16px

    //Set up pages with empty ArrayList
    elements = new ArrayList<ArrayList<InputElement>>();
    for(int i = 0; i < numPages; i++){
        elements.add(new ArrayList<InputElement>());
    }

    addElements(elements); //Initialize buttons and sliders
    readSettings();
    position = 0;

    //Algin elements to grid
    int[] menuLayout = {1, 1, 1, 2};
    alignToGrid(elements.get(MAIN_MENU), 50, 10, menuLayout); //Align with 50px of padding, 10px of element padding, and with 1 columns

    alignToGrid(elements.get(EFFECTS), 50, 10, 3); //Align with 50px of padding, 10px of element padding, and with 3 columns
    int[] effectSettingsLayout = {1, 3, 1, 2, 1, 1};
    alignToGrid(elements.get(EFFECT_SETTINGS), 50, 10, effectSettingsLayout); //Align with 50px of padding, 10px of element padding, and with 1 columns

    int[] ledSettingsLayout = {2, 2, 3, 1};
    alignToGrid(elements.get(LED_SETTINGS), 50, 10, ledSettingsLayout); //Align with 50px of padding, 10px of element padding, and with 1 columns

    delay = (int)elements.get(EFFECT_SETTINGS).get(0).getValue();
    lastUpdate = millis();
    port = new Serial(this, Serial.list()[0], 500000);
    port.clear();


    amp = new Amplitude(this);
    in = new AudioIn(this, 0);
    in.start();
    amp.input(in);

    writeSettings("data\\default_settings.dat");
    loadSettings("settings.dat");
}

void draw() {
    background(255);
    for(InputElement b : elements.get(pageNumber)){
        b.checkMouse();
        b.render();
    }

    String title;
    switch(pageNumber){
        case MAIN_MENU: title = "Main Menu"; break;
        case EFFECTS: title = "Effects"; break;
        case EFFECT_SETTINGS: title = "Effect Settings"; break;
        case LED_SETTINGS: title = "LED Settings"; break;
        default: title = "INVALID PAGE INDEX"; break;
    }
    textSize(titleHeight);
    fill(0);
    text(title, width / 2, titleHeight / 2);

    readSettings();
    if(elements.get(LED_SETTINGS).get(0).getValue() != 0){
        if(!effects.contains(Effect.BREATHE)){
            addEffect(Effect.BREATHE);
        }
    } else{
        effects.remove((Integer)Effect.BREATHE);
    }
    if(elements.get(LED_SETTINGS).get(2).getValue() == 0){
        if(!effects.contains(Effect.BLINK)){
            addEffect(Effect.OFF);
        }
    } else{
        effects.remove((Integer)Effect.OFF);
    }
    if(elements.get(LED_SETTINGS).get(4).getValue() != 0){
        if(!effects.contains(Effect.BLINK)){
            println(effects);
            addEffect(Effect.BLINK);
        }
    } else{
        effects.remove((Integer)Effect.BLINK);
    }
    vol = amp.analyze();
    delay = (int)elements.get(EFFECT_SETTINGS).get(0).getValue();
    strip.setBrightness(maxBrightness);

    if(millis() >= lastUpdate + delay){
        applyEffects();
        strip.update(port);
        lastUpdate = millis();
        position++;
    }
}

//Given the contents of a page, padding between edge of window, padding between elements, and number of columns, aligns elements to a grid
void alignToGrid(ArrayList<InputElement> elements, int padding, int elementPadding, int cols){
    int rows = ceil(elements.size() / cols);
    float usableWidth = width - padding * 2;
    float usableHeight = height - padding * 2 - titleHeight;
    float colWidth = usableWidth / cols;
    float rowHeight = usableHeight / rows;
    float boxWidth = colWidth - elementPadding * 2;
    float boxHeight = rowHeight - elementPadding * 2;

    for(int r = 0; r < rows; r++){
        for(int c = 0; c < cols; c++){
            float x = padding + (c + 1 / 2.0) * colWidth;
            float y = padding + (r + 1 / 2.0) * rowHeight + titleHeight;
            if(r * cols + c < elements.size()){
                elements.get(r * cols + c).setBox(x, y, boxWidth, boxHeight);
            }
        }
    }
}

//Allows you to specify uneven grid
void alignToGrid(ArrayList<InputElement> elements, int padding, int elementPadding, int[] rowCols){
    int rows = rowCols.length;
    float usableWidth = width - padding * 2;
    float usableHeight = height - padding * 2 - titleHeight;
    float colWidth;
    float rowHeight = usableHeight / rows;
    float boxWidth;
    float boxHeight = rowHeight - elementPadding * 2;
    int count = 0;

    for(int r = 0; r < rows; r++){
        int cols = rowCols[r];
        colWidth = usableWidth / cols;
        boxWidth = colWidth - elementPadding * 2;
        for(int c = 0; c < cols; c++){
            float x = padding + (c + 1 / 2.0) * colWidth;
            float y = padding + (r + 1 / 2.0) * rowHeight + titleHeight;
            if(count < elements.size()){
                elements.get(count).setBox(x, y, boxWidth, boxHeight);
                count++;
            }
        }
    }
}

void writeSettings(String filename){
    PrintWriter settings = createWriter(filename);
    String line = "";
    for(int i = 0; i < elements.size(); i++){
        line += i + " ";
        for(int j = 0; j < elements.get(i).size(); j++){
            line += elements.get(i).get(j).getValue() + " ";
        }
        line.trim();
        settings.println(line);
        line = "";
    }
    settings.close();
}

void loadSettings(String filename){
    String[] lines = loadStrings(filename);
    Scanner chopper;
    String line;
    for(int i = 0; i < lines.length; i++){
        line = lines[i];
        chopper = new Scanner(line);
        int index = chopper.nextInt();
        for(int j = 0; j < elements.get(index).size(); j++){
            elements.get(index).get(j).setValue(chopper.nextFloat());
        }
    }
}

//Where the InputElements and their effects are created
void addElements(ArrayList<ArrayList<InputElement>> elements){
//=========================== MAIN MENU ===========================//
    elements.get(MAIN_MENU).add(new Button("Effects", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(EFFECTS);
            }
        }
    ));

    elements.get(MAIN_MENU).add(new Button("Effect Settings", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(EFFECT_SETTINGS);
            }
        }
    ));

    elements.get(MAIN_MENU).add(new Button("LED Strip Settings", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(LED_SETTINGS);
            }
        }
    ));

    elements.get(MAIN_MENU).add(new Button("Save Settings", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                writeSettings("data\\settings.dat");
            }
        }
    ));

    elements.get(MAIN_MENU).add(new Button("Restore Default Settings", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                loadSettings("default_settings.dat");
            }
        }
    ));

//=========================== EFFECTS PAGE ===========================//
    elements.get(EFFECTS).add(new Button("Solid Color", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                addEffect(Effect.SOLID);
                resetSelected(EFFECTS, 0);
                clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Rainbow Wave", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                addEffect(Effect.RB_WAVE);
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Solid Rainbow", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                addEffect(Effect.RB_SOLID);
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Pulse Rainbow", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                addEffect(Effect.RB_PULSE);
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Wander", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                addEffect(Effect.WANDER);
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("USA", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                addEffect(Effect.USA);
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Music Reactive", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                addEffect(Effect.MUSIC);
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Video Reactive", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                addEffect(Effect.VIDEO);
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("BACK TO MAIN MENU", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(MAIN_MENU);
            }
        }
    ));

//=========================== EFFECT SETTINGS PAGE ===========================//
    elements.get(EFFECT_SETTINGS).add(new Slider("Effect Delay", "ms", 10, 0, 300, 25, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Red Channel", "", 1, 0, 255, 0, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Green Channel", "", 1, 0, 255, 0, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Blue Channel", "", 1, 0, 255, 255, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Music Color Speed", " pixels/second", 1, 1, strip.length() / 2, 20, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Rainbow Frequency", "", 100, 0.01, 3.14, 0.1, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Rainbow Pulse Delay", "ms", 1, 1, 5000, 500, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("USA Color Length", " pixels", 1, 1, strip.length(), 24, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Button("BACK TO MAIN MENU", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(MAIN_MENU);
            }
        }
    ));

//=========================== LED SETTINGS PAGE ===========================//
    elements.get(LED_SETTINGS).add(new Button("Breathe", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
				clicked();
            }
        }
    ));

    elements.get(LED_SETTINGS).add(new Slider("Breathe Frequency", "", 100, 0.01, 3.14, 0.1, INPUT_STYLE, true));

    elements.get(LED_SETTINGS).add(new Button("Strip On", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
				clicked();
            }
        }
    ));
    elements.get(LED_SETTINGS).get(elements.get(LED_SETTINGS).size() - 1).setValue(1);

    elements.get(LED_SETTINGS).add(new Slider("Max Brightness", "%", 10, 0, 100, 50, INPUT_STYLE, true));

    elements.get(LED_SETTINGS).add(new Button("Blink", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
				clicked();
            }
        }
    ));

    elements.get(LED_SETTINGS).add(new Slider("Blink Length", "ms", 1, 1, 10000, 500, INPUT_STYLE, true));

    elements.get(LED_SETTINGS).add(new Slider("Time Between Blinks", "ms", 1, 1, 10000, 3000, INPUT_STYLE, true));

    elements.get(LED_SETTINGS).add(new Button("BACK TO MAIN MENU", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(MAIN_MENU);
            }
        }
    ));
}

void addEffect(int effectId){
    //If adding a non global effect, remove all non-globals then add it
    if(!effectHandler.isGlobal(effectId)){
        for(int i = effects.size() - 1; i >= 0; i--){
            if(!effectHandler.isGlobal(effects.get(i))){
                effects.remove(i);
            }
        }
    }
    effects.add(effectId);

    //Arrange global effects according to priority
    if(effects.remove((Integer)Effect.BREATHE)){
        effects.add(Effect.BREATHE);
    }
    if(effects.remove((Integer)Effect.BLINK)){
        effects.add(Effect.BLINK);
    }
    if(effects.remove((Integer)Effect.OFF)){
        effects.add(Effect.OFF);
    }
}

//Update various settings variables
void readSettings(){
    int r = (int)elements.get(EFFECT_SETTINGS).get(1).getValue();
    int g = (int)elements.get(EFFECT_SETTINGS).get(2).getValue();
    int b = (int)elements.get(EFFECT_SETTINGS).get(3).getValue();
    speed = elements.get(EFFECT_SETTINGS).get(4).getValue();
    solidColor = color(r, g, b);
    rbFreq = elements.get(EFFECT_SETTINGS).get(5).getValue();
    pulseDelay = elements.get(EFFECT_SETTINGS).get(6).getValue();
    usaFreq = elements.get(EFFECT_SETTINGS).get(7).getValue();
    breatheFreq = elements.get(LED_SETTINGS).get(1).getValue();
    maxBrightness = elements.get(LED_SETTINGS).get(3).getValue();
    blinkLength = elements.get(LED_SETTINGS).get(5).getValue();
    blinkDelay = elements.get(LED_SETTINGS).get(6).getValue();
}

void applyEffects(){
    float[] settings = {0.0};
    ArrayList<InputElement> effectsPage = elements.get(EFFECTS);
    ArrayList<InputElement> ledSettingsPage = elements.get(LED_SETTINGS);
    for(int eff : effects){
        if(eff == Effect.SOLID){
            settings = new float[]{solidColor};
        }
        if(eff == Effect.RB_WAVE){
            settings = new float[]{rbFreq, position};
        }
        if(eff == Effect.RB_SOLID){
            settings = new float[]{rbFreq, position};
        }
        if(eff == Effect.RB_PULSE){
            settings = new float[]{pulseDelay, position};
        }
        if(eff == Effect.USA){
            settings = new float[]{usaFreq, position};
        }
        if(eff == Effect.MUSIC){
            settings = new float[]{speed, vol};
        }
        if(eff == Effect.BREATHE){
            settings = new float[]{breatheFreq, position, maxBrightness};
        }
        if(eff == Effect.BLINK){
            settings = new float[]{blinkLength, blinkDelay};
        }
        effectHandler.fromID(eff, settings);
    }
}

//Given the index of a page, go to it and disable all other buttons
void jumpTo(int pageIndex){
    pageNumber = pageIndex;
    for(int i = 0; i < numPages; i++){
        for(int j = 0; j < elements.get(i).size(); j++){
            elements.get(i).get(j).setClicked(true);
        }
    }
}

//Disables all other buttons so there is only one action per click
void clicked(){
    for(int i = 0; i < numPages; i++){
        for(int j = 0; j < elements.get(i).size(); j++){
            elements.get(i).get(j).setClicked(true);
        }
    }
}

//Resets all toggleable buttons on specified page to specified value
void resetSelected(int pageNum, float value){
    InputElement element;
    for(int i = 0; i < elements.get(pageNum).size(); i++){
        element = elements.get(pageNum).get(i);
        if(element instanceof Button){
            element.setValue(value);
        }
    }
}
