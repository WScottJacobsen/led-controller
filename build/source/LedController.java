import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Scanner; 
import processing.serial.*; 
import java.awt.AWTException; 
import java.awt.Dimension; 
import java.awt.Rectangle; 
import java.awt.Robot; 
import java.awt.Toolkit; 
import java.awt.image.BufferedImage; 
import java.io.IOException; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LedController extends PApplet {











ArrayList<ArrayList<InputElement>> elements; //Holds all buttons and sliders, each ArrayList<InputElement> represents a "page"
int numPages = 4; //Total number of pages
final int MAIN_MENU = 0, EFFECTS = 1, EFFECT_SETTINGS = 2, LED_SETTINGS = 3;
int pageNumber = MAIN_MENU; //Page that is visible
Style INPUT_STYLE;
float titleHeight = 50.0f;
Strip strip = new Strip(288); //Initialize strip with 288 led
ArrayList<Integer> effects = new ArrayList<Integer>();
int delay, lastUpdate;
float blinkLength, blinkDelay, position, solidColor, rbFreq, pulseDelay, usaFreq, musicSensitivity, breatheFreq, maxBrightness;
Serial port;
Effect effectHandler = new Effect(strip);

//Initialize variables and create and align InputElements
public void setup() {
    
    rectMode(CENTER); //Draw rectangles from the center point
    INPUT_STYLE = new Style(0xff000000, 0xffFFFFFF, 0xffFFFFFF, 0xff000000, 0xff000000, 1, createFont("mononoki.ttf", 16, true), 16); //Black text on white background with black outline, inverted colors when hovered, mononoki font at 16px

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
    //port = new Serial(this, Serial.list()[0], 9600);

    writeSettings("data\\default_settings.dat");
    loadSettings("settings.dat");
}

public void draw() {
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
        addEffect(Effect.BREATHE);
    } else{
        effects.remove((Integer)Effect.BREATHE);
    }
    if(elements.get(LED_SETTINGS).get(2).getValue() != 0){
        addEffect(Effect.OFF);
    } else{
        effects.remove((Integer)Effect.OFF);
    }
    if(elements.get(LED_SETTINGS).get(3).getValue() != 0){
        addEffect(Effect.BLINK);
    } else{
        effects.remove((Integer)Effect.BLINK);
    }
    delay = (int)elements.get(EFFECT_SETTINGS).get(0).getValue();
    strip.setBrightness(maxBrightness);
    if(millis() >= lastUpdate + delay){
        applyEffects();
        //strip.update(port);
        lastUpdate = millis();
        position++;
    }
}

//Given the contents of a page, padding between edge of window, padding between elements, and number of columns, aligns elements to a grid
public void alignToGrid(ArrayList<InputElement> elements, int padding, int elementPadding, int cols){
    int rows = ceil(elements.size() / cols);
    float usableWidth = width - padding * 2;
    float usableHeight = height - padding * 2 - titleHeight;
    float colWidth = usableWidth / cols;
    float rowHeight = usableHeight / rows;
    float boxWidth = colWidth - elementPadding * 2;
    float boxHeight = rowHeight - elementPadding * 2;

    for(int r = 0; r < rows; r++){
        for(int c = 0; c < cols; c++){
            float x = padding + (c + 1 / 2.0f) * colWidth;
            float y = padding + (r + 1 / 2.0f) * rowHeight + titleHeight;
            if(r * cols + c < elements.size()){
                elements.get(r * cols + c).setBox(x, y, boxWidth, boxHeight);
            }
        }
    }
}

//Allows you to specify uneven grid
public void alignToGrid(ArrayList<InputElement> elements, int padding, int elementPadding, int[] rowCols){
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
            float x = padding + (c + 1 / 2.0f) * colWidth;
            float y = padding + (r + 1 / 2.0f) * rowHeight + titleHeight;
            if(count < elements.size()){
                elements.get(count).setBox(x, y, boxWidth, boxHeight);
                count++;
            }
        }
    }
}

public void writeSettings(String filename){
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

public void loadSettings(String filename){
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
public void addElements(ArrayList<ArrayList<InputElement>> elements){
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

    elements.get(EFFECT_SETTINGS).add(new Slider("Music Sensitivity", "%", 1, 0, 100, 50, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Rainbow Frequency", "", 100, 0.01f, 3.14f, 0.1f, INPUT_STYLE, true));

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

    elements.get(LED_SETTINGS).add(new Slider("Breathe Frequency", "", 100, 0.01f, 3.14f, 0.1f, INPUT_STYLE, true));

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

public void addEffect(int effectId){
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
public void readSettings(){
    int r = (int)elements.get(EFFECT_SETTINGS).get(1).getValue();
    int g = (int)elements.get(EFFECT_SETTINGS).get(2).getValue();
    int b = (int)elements.get(EFFECT_SETTINGS).get(3).getValue();
    musicSensitivity = elements.get(EFFECT_SETTINGS).get(4).getValue();
    solidColor = color(r, g, b);
    rbFreq = elements.get(EFFECT_SETTINGS).get(5).getValue();
    pulseDelay = elements.get(EFFECT_SETTINGS).get(6).getValue();
    usaFreq = elements.get(EFFECT_SETTINGS).get(7).getValue();
    breatheFreq = elements.get(LED_SETTINGS).get(1).getValue();
    maxBrightness = elements.get(LED_SETTINGS).get(3).getValue();
    blinkLength = elements.get(LED_SETTINGS).get(5).getValue();
    blinkDelay = elements.get(LED_SETTINGS).get(6).getValue();
}

public void applyEffects(){
    float[] settings = {0.0f};
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
            settings = new float[]{musicSensitivity};
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
public void jumpTo(int pageIndex){
    pageNumber = pageIndex;
    for(int i = 0; i < numPages; i++){
        for(int j = 0; j < elements.get(i).size(); j++){
            elements.get(i).get(j).setClicked(true);
        }
    }
}

//Disables all other buttons so there is only one action per click
public void clicked(){
    for(int i = 0; i < numPages; i++){
        for(int j = 0; j < elements.get(i).size(); j++){
            elements.get(i).get(j).setClicked(true);
        }
    }
}

//Resets all toggleable buttons on specified page to specified value
public void resetSelected(int pageNum, float value){
    InputElement element;
    for(int i = 0; i < elements.get(pageNum).size(); i++){
        element = elements.get(pageNum).get(i);
        if(element instanceof Button){
            element.setValue(value);
        }
    }
}
class Button implements InputElement{
    private Rectangle hitbox;
    private String text;
    private ButtonAction action;
    private boolean hover, clicked, enabled, toggleable, toggled;
    private Style style;
    private float value;

    Button(String text, Rectangle hitbox, Style style, boolean enabled, boolean toggleable, ButtonAction action){
        this.text = text;
        this.hitbox = hitbox;
        this.style = style;
        this.action = action;
        this.enabled = enabled;
        this.toggleable = toggleable;
        this.toggled = false;
        this.hover = false;
        this.clicked = false;
    }

    Button(String text, Style style, boolean enabled, boolean toggleable, ButtonAction action){
        this.text = text;
        this.hitbox = new Rectangle(0, 0, 0, 0);
        this.style = style;
        this.action = action;
        this.enabled = enabled;
        this.toggleable = toggleable;
        this.toggled = false;
        this.hover = false;
        this.clicked = false;
    }

    public float getValue(){
        return toggled ? 1 : 0;
    }

    public void setValue(float value){
        toggled = value == 0 ? false : true;
    }

    public void checkMouse(){
        if(hitbox.inside(mouseX, mouseY)) {
            hover = true;
            if(!mousePressed){
                clicked = false;
            } else if(!clicked && enabled){
                boolean tempValue = toggled;
                action.execute();
                if(toggleable){
                    setValue(tempValue ? 0 : 1);
                }
                clicked = true;
            }
        } else{
            hover = false;
        }
    }

    public void setBox(float x, float y, float w, float h){
        hitbox.set(x, y, w, h);
    }

    public void setEnabled(boolean value){
        enabled = value;
    }

    public boolean isEnabled(){
        return enabled;
    }

    public void setClicked(boolean value){
        clicked = value;
    }

    public void render(){
        int txtColor = style.getTextColor(), bgColor = style.getBackgroundColor();
        if(hover && enabled || toggled){
            txtColor = style.getTextHover();
            bgColor = style.getBackgroundHover();
        }
        if(style.hasStroke()){
            stroke(style.getStrokeColor());
            strokeWeight(style.getStrokeWeight());
        } else{
            noStroke();
        }

        float[] rectComponents = hitbox.getComponents();
        float x = rectComponents[0];
        float y = rectComponents[1];
        float w = rectComponents[2];
        float h = rectComponents[3];

        fill(bgColor);
        rect(x, y, w, h);

        textAlign(CENTER, TOP);
        textFont(style.getFont(), style.getFontSize());
        fill(txtColor);
        text(text, x, y - style.getFontSize() / 2);
    }
}
interface ButtonAction{
    public void execute(); //Action preformed on click
}
class Effect{
    static final int SOLID = 0, RB_WAVE = 1, RB_SOLID = 2, RB_PULSE = 3, WANDER = 4, USA = 5, MUSIC = 6, VIDEO = 7, BREATHE = 8, BLINK = 9, OFF = 10;
    private final int[] globalEffects = {BREATHE, BLINK, OFF}; //A global effect is one that can be applied on top of another effect
    private Strip strip;
    private int blinkStart = 0, prevPulse = 0;
    private boolean blinking = false;
    private float tempBrightness = 0;

    Effect(Strip s){
        strip = s;
    }

    public void fromID(int id, float[] settings){
        switch(id){
            case SOLID: setAll((int)settings[0]); break; //Setting: color
            case RB_WAVE: rbWave(settings); break; //Settings: rainbow speed, position
            case RB_SOLID: rbSolid(settings); break; //Setting: rainbow speed, position
            case RB_PULSE: rbPulse(settings); break; //Setting: speed, position
            case WANDER: wander(); break;
            case USA: usa(settings); break; //Setting: frequency, position
            case MUSIC: music(settings); break; //Setting: sensitivity
            case VIDEO: video(); break;
            case BREATHE: breathe(settings); break;  //Setting: speed, pos, max brightness
            case BLINK: blink(settings); break;  //Setting: blink length, blink delay
            case OFF: off(); break;
        }
    }

    public boolean isGlobal(int id){
        for(int i = 0; i < globalEffects.length; i++){
            if(globalEffects[i] == id){
                return true;
            }
        }
        return false;
    }

//=========================== HELPER FUNCTIONS ===========================//

    private int rgbToHex(int r, int g, int b){
        return ((r & 0xFF) << 16) + ((g & 0xFF) << 8) + (b & 0xFF);
    }

    private int[] hexToRgb(int col){
        int r = ((col >> 16) & 0xFF);
        int g = ((col >> 8) & 0xFF);
        int b = ((col) & 0xFF);
        int[] result = {r, g, b};
        return result;
    }

    private int getRainbowColor(float frequency, float position){
        // Uses three out of sync sin waves to have a smooth transition between colors
        //Frequency is how quickly it moves throught the rainbow
        //Position is where in the rainbow it is
        int red = (int)(sin(frequency * position) * 127 + 128);
        int green = (int)(sin(frequency * position + 2 * PI / 3) * 127 + 128);
        int blue = (int)(sin(frequency * position + 4 * PI / 3) * 127 + 128);
        return rgbToHex(red, green, blue);
    }

    private void setAll(int col){
        for(int i = 0; i < strip.length(); i++){
            strip.set(i, col);
        }
    }

//=============================== EFFECTS ==============================//

    public void rbWave(float[] settings){
        float freq = settings[0];
        int pos = (int)settings[1];
        for(int i = 0; i < strip.length(); i++){
            strip.set(i, getRainbowColor(freq, i + pos));
        }
    }

    public void rbSolid(float[] settings){
        float freq = settings[0];
        int pos = (int)settings[1];
        setAll(getRainbowColor(freq, pos));
    }

    public void rbPulse(float[] settings){
        int speed = (int)settings[0];
        int pos = (int)settings[1];
        //                         red      orange    yellow    green      blue     indigo    violet
        int[] rainbowColors = {0xFF0000, 0xFFA500, 0xFFFF00, 0x00FF00, 0x0000FF, 0x4B0082, 0xEE82EE};
        if(millis() >= prevPulse + speed){
            int col = rainbowColors[pos % rainbowColors.length];
            setAll(col);
            prevPulse = millis();
        }
    }

    public void wander(){
        // Get current color of each pixel, change it to hsb, increment hue value, convert back to rgb and set color
        colorMode(RGB);
        for(int i = 0; i < strip.length(); i++){
            int tempCol = strip.getColor(i);
            int[] rgb = hexToRgb(tempCol);
            int col = color(rgb[0], rgb[1], rgb[2]);
            colorMode(HSB);
            col = color(hue(col) + random(-1, 3), saturation(col), brightness(col));
            colorMode(RGB);
            strip.set(i, col);
        }
    }

    public void usa(float[] settings){
        float freq = settings[0];
        int pos = (int)settings[1];
        //                Red       White     Blue
        int[] colors = {0xFF0000, 0xFFFFFF, 0x0000FF};
        int colorInd = 0;
        int col;
        for(int i = 0; i < strip.length() / freq; i++){
            col = colors[colorInd];
            for(int j = 0; j < freq; j++){
                strip.set(i * j + j, col);
            }
            colorInd++;
            colorInd %= colors.length;
        }
    }

    public void music(float settings[]){
        float sensitivity = settings[0];
    }

    public void video(){
        Robot screenReader = null;
		try {
			screenReader = new Robot();
		} catch (AWTException e) {
			println(e);
		}
		Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        int w = screenSize.width, h = screenSize.height;
		BufferedImage sc = screenReader.createScreenCapture(new java.awt.Rectangle(w, h));
        long totalR = 0, totalG = 0, totalB = 0;
        int[] rgb;
        for(int i = 0; i < w; i++){
            for(int j = 0; j < h; j++){
                rgb = hexToRgb(sc.getRGB(i, j));
                totalR += rgb[0];
                totalG += rgb[1];
                totalB += rgb[2];
            }
        }
        totalR /= w * h;
        totalG /= w * h;
        totalB /= w * h;
        int col = rgbToHex((int)totalR, (int)totalG, (int)totalB);
        setAll(col);
    }

    public void breathe(float[] settings){
        float freq = settings[0];
        int pos = (int)settings[1];
        float maxBrightness = settings[2];
        float brightness = map(sin(freq * pos), -1, 1, 0, 100);
        strip.setBrightness(brightness);
    }

    public void blink(float[] settings){
        int blinkLength = (int)settings[0];
        int blinkDelay = (int)settings[1];
        if(!blinking && millis() >= blinkStart + blinkDelay){
            tempBrightness = strip.getBrightness();
            blinkStart = millis();
            blinking = true;
            strip.setBrightness(0);
        } else if(blinking && millis() <= blinkLength + blinkStart){
            strip.setBrightness(0);
        } else if(blinking){
            blinkStart = millis();
            blinking = false;
            strip.setBrightness(tempBrightness);
        }
    }

    public void off(){
        setAll(0x000000); //Not sure which will work, need to test
        //strip.setBrightness(0);
    }
}
interface InputElement{
    public void checkMouse(); //Check if intersecting with hitbox, preform action when necessary
    public void render(); //Draws element
    public void setEnabled(boolean value); //Changes if user can interact with element
    public boolean isEnabled(); //Checks if user can interact with element
    public void setBox(float x, float y, float w, float h); //Change hitbox for element
    public void setClicked(boolean value); //Tells whether or not to wait to new click before performing action
    public float getValue(); //Returns value of element, 0 is false, everything else is true
    public void setValue(float value); //Sets value of element
}
class Rectangle{
    private float x, y, w, h;

    Rectangle(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    public void set(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    public boolean inside(float xPos, float yPos){
        return (xPos >= x - w / 2 && xPos <= x + w / 2) && (yPos >= y - h / 2 && yPos <= y + h / 2);
    }

    public float[] getComponents(){
        float[] components = {x, y, w, h};
        return components;
    }
}
static boolean interacting = false; //Very bad way to prevent interacting with multiple sliders at once, but I didn't plan ahead
class Slider implements InputElement{
    private float step, min, max, value;
    private String text, unit;
    private Rectangle totalHitbox, bar, tab; //Rectange surrounding text and slider, just the bar of the slider, and the thing that you slide
    private Style style;
    private boolean enabled, clicked, hover;

    Slider(String text, String unit, float step, float min, float max, float value, Rectangle hitbox, Style style, boolean enabled){
        this.text = text;
        this.unit = unit;
        this.step = step;
        this.totalHitbox = hitbox;
        this.tab = new Rectangle(0, 0, 0, 0);
        this.bar = new Rectangle(0, 0, 0, 0);
        generateBoxes();
        this.style = style;
        this.min = min;
        this.max = max;
        this.value = value;
        this.enabled = enabled;
        this.clicked = false;
    }

    Slider(String text, String unit, float step, float min, float max, float value, Style style, boolean enabled){
        this.text = text;
        this.unit = unit;
        this.step = step;
        this.style = style;
        this.totalHitbox = new Rectangle(0, 0, 0, 0);
        this.tab = new Rectangle(0, 0, 0, 0);
        this.bar = new Rectangle(0, 0, 0, 0);
        this.min = min;
        this.max = max;
        this.value = value;
        this.enabled = enabled;
        this.clicked = false;
    }

    private void generateBoxes(){
        float[] components = totalHitbox.getComponents();
        float x = components[0];
        float y = components[1];
        float w = components[2];
        float h = components[3];
        float barHeight = h / 16;
        float tabHeight = h / 4;
        float tabWidth = w / 32;
        float tabX = map(value, min, max, x - w / 2, x + w / 2);
        bar = new Rectangle(x, y, w, barHeight);
        tab = new Rectangle(tabX, y, tabWidth, tabHeight);
    }

    public void setBox(float x, float y, float w, float h){
        totalHitbox.set(x, y, w, h);
        generateBoxes();
    }

    public void setValue(float value){
        this.value = value;
        float[] tabComponents = tab.getComponents();
        float[] components = totalHitbox.getComponents();
        float x = components[0];
        float w = components[2];
        float xPos = map(value, min, max, x - w / 2, x + w / 2);
        tab.set(xPos, tabComponents[1], tabComponents[2], tabComponents[3]);
    }

    public float getValue(){
        return value;
    }

    public void setEnabled(boolean val){
        this.enabled = val;
    }

    public boolean isEnabled(){
        return enabled;
    }

    public void setClicked(boolean val){
        this.clicked = val;
    }

    public void checkMouse(){
        if(!mousePressed){
            clicked = true;
            hover = false;
            interacting = false;
        } else if((tab.inside(mouseX, mouseY) || bar.inside(mouseX, mouseY)) && enabled && !interacting || !clicked){
            clicked = false;
            hover = true;
            interacting = true;
            float[] components = totalHitbox.getComponents();
            float x = components[0];
            float w = components[2];
            float[] tabComponents = tab.getComponents();
            float xPos = constrain(mouseX, x - w / 2, x + w / 2);
            tab.set(xPos, tabComponents[1], tabComponents[2], tabComponents[3]);
            value = map(xPos, x - w / 2, x + w / 2, min, max);
        }
        value = round(value * step) / step;
    }

    public void render(){
        int txtColor = style.getTextColor(), bgColor = style.getBackgroundColor();
        if(style.hasStroke()){
            stroke(style.getStrokeColor());
            strokeWeight(style.getStrokeWeight());
        } else{
            noStroke();
        }

        float[] barComponents = bar.getComponents();
        float x = barComponents[0];
        float y = barComponents[1];
        float w = barComponents[2];
        float h = barComponents[3];
        fill(style.getStrokeColor());
        rect(x, y, w, h);

        if(hover && enabled){
            stroke(style.getTextHover());
            bgColor = style.getBackgroundHover();
        }

        float[] tabComponents = tab.getComponents();
        x = tabComponents[0];
        y = tabComponents[1];
        w = tabComponents[2];
        h = tabComponents[3];
        fill(bgColor);
        rect(x, y, w, h);

        float[] rectComponents = totalHitbox.getComponents();
        x = rectComponents[0];
        y = rectComponents[1];
        w = rectComponents[2];
        h = rectComponents[3];
        textAlign(CENTER, TOP);
        textFont(style.getFont(), style.getFontSize());
        fill(txtColor);
        text(text, x, y - h / 4 - style.getFontSize() / 2);

        //If value increases in whole numbers and starts out as a while number, remove decimal point
        if((1 / step) == (int)(1 / step) && value == (int)value){
            text((int)value + unit, x, y + h / 4 - style.getFontSize() / 2);
        } else{
            text(value + unit, x, y + h / 4 - style.getFontSize() / 2);
        }
    }
}
class Strip{
    private int ledCount;
    private float brightness;
    private int[] leds;
    private long clockSpeed;

    Strip(int ledCount){
        this.ledCount = ledCount;
        this.leds = new int[ledCount];
        this.clockSpeed = 800000;
        this.brightness = 50.0f;
    }

    Strip(int ledCount, long clockSpeed){
        this.ledCount = ledCount;
        this.leds = new int[ledCount];
        this.clockSpeed = clockSpeed;
        this.brightness = 50.0f;
    }

    public int length(){
        return ledCount;
    }

    public void init(Serial port){
        port.write(ledCount + ";");
        port.write(clockSpeed + ";");
    }

    public void set(int pixel, int col){
        leds[pixel] = col;
    }

    public int getColor(int pixel){
        return leds[pixel];
    }

    public void setBrightness(float brightness){
        this.brightness = brightness;
    }

    public float getBrightness(){
        return brightness;
    }

    public void update(Serial port){
        byte[] stream = new byte[ledCount * 3];
        for(int i = 0; i < ledCount; i++){
            int col = leds[i];
            stream[i] = (byte)(col >> 16 & 0xFF);
            stream[i + 1] = (byte)(col >> 8 & 0xFF);
            stream[i + 2] = (byte)(col & 0xFF);
        }
        port.write(stream);
        port.write("" + brightness);
    }
}
//Basically just a bunch of getters and setters
class Style{
    private int txtColor, txtHover, bgColor, bgHover, strokeColor;
    private PFont font;
    private int fontSize, strokeWeight;
    private boolean stroke;

    Style(int txtColor, int txtHover, int bgColor, int bgHover, int strokeColor, int strokeWeight, PFont font, int fontSize){
        this.txtColor = txtColor;
        this.txtHover = txtHover;
        this.bgColor = bgColor;
        this.bgHover = bgHover;
        this.strokeColor = strokeColor;
        this.strokeWeight = strokeWeight;
        this.font = font;
        this.fontSize = fontSize;
        this.stroke = true;
    }

    public void Style(int txtColor, int txtHover, int bgColor, int bgHover, PFont font, int fontSize){
        this.txtColor = txtColor;
        this.txtHover = txtHover;
        this.bgColor = bgColor;
        this.bgHover = bgHover;
        this.strokeColor = strokeColor;
        this.strokeWeight = strokeWeight;
        this.font = font;
        this.fontSize = fontSize;
        this.stroke = false;
    }

    public boolean hasStroke(){
        return stroke;
    }

    public int getStrokeColor(){
        return strokeColor;
    }

    public int getStrokeWeight(){
        return strokeWeight;
    }

    public int getTextColor(){
        return txtColor;
    }

    public int getTextHover(){
        return txtHover;
    }

    public int getBackgroundColor(){
        return bgColor;
    }

    public int getBackgroundHover(){
        return bgHover;
    }

    public PFont getFont(){
        return font;
    }

    public int getFontSize(){
        return fontSize;
    }
}
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "LedController" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
