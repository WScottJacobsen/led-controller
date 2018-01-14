import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LedController extends PApplet {

//TODO: Add sliders

ArrayList<ArrayList<InputElement>> elements; //Holds all buttons and sliders, each ArrayList<InputElement> represents a "page"
int numPages = 4; //Total number of pages
final int MAIN_MENU = 0, EFFECTS = 1, EFFECT_SETTINGS = 2, LED_SETTINGS = 3;
int pageNumber = MAIN_MENU; //Page that is visible
Style BUTTON_STYLE;
float titleHeight = 50.0f;

//Initialize variables and create and align InputElements
public void setup() {
    
    rectMode(CENTER); //Draw rectangles from the center point
    BUTTON_STYLE = new Style(0xff000000, 0xffFFFFFF, 0xffFFFFFF, 0xff000000, 0xff000000, 2, createFont("mononoki.ttf", 16, true), 16); //Black text on white background with black outline, inverted colors when hovered, mononoki font at 16px

    //Set up pages with empty ArrayList
    elements = new ArrayList<ArrayList<InputElement>>();
    for(int i = 0; i < numPages; i++){
        elements.add(new ArrayList<InputElement>());
    }

    addElements(elements); //Initialize buttons and sliders

    //Algin elements to grid
    alignToGrid(elements.get(MAIN_MENU), 50, 10, 1); //Align with 50px of padding, 10px of element padding, and with 1 columns
    alignToGrid(elements.get(EFFECTS), 50, 10, 3); //Align with 50px of padding, 10px of element padding, and with 3 columns
    alignToGrid(elements.get(EFFECT_SETTINGS), 50, 10, 1); //Align with 50px of padding, 10px of element padding, and with 1 columns
    alignToGrid(elements.get(LED_SETTINGS), 50, 10, 1); //Align with 50px of padding, 10px of element padding, and with 1 columns
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

//Where the InputElements and their effects are created
public void addElements(ArrayList<ArrayList<InputElement>> elements){
//=========================== MAIN MENU ===========================//
    elements.get(MAIN_MENU).add(new Button("Effects", BUTTON_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(EFFECTS);
            }
        }
    ));

    elements.get(MAIN_MENU).add(new Button("Effect Settings", BUTTON_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(EFFECT_SETTINGS);
            }
        }
    ));

    elements.get(MAIN_MENU).add(new Button("LED Strip Settings", BUTTON_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(LED_SETTINGS);
            }
        }
    ));

//=========================== EFFECTS PAGE ===========================//
    elements.get(EFFECTS).add(new Button("Rainbow Wave", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Solid Rainbow", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Pulse Rainbow", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Wander", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("USA", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Music Reactive", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Video Reactive", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Solid Color", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));
    //elements.get(EFFECTS).get(elements.get(EFFECTS).size() - 1).setValue(1);

    elements.get(EFFECTS).add(new Button("BACK TO MAIN MENU", BUTTON_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(MAIN_MENU);
            }
        }
    ));

//=========================== EFFECT SETTINGS PAGE ===========================//
    elements.get(EFFECT_SETTINGS).add(new Button("BACK TO MAIN MENU", BUTTON_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(MAIN_MENU);
            }
        }
    ));

//=========================== LED SETTINGS PAGE ===========================//
    elements.get(LED_SETTINGS).add(new Button("Breathe", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(LED_SETTINGS, 0);
				clicked();
            }
        }
    ));

    elements.get(LED_SETTINGS).add(new Button("Blink", BUTTON_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(LED_SETTINGS, 0);
				clicked();
            }
        }
    ));
    elements.get(LED_SETTINGS).add(new Button("BACK TO MAIN MENU", BUTTON_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(MAIN_MENU);
            }
        }
    ));
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
    for(int i = 0; i < elements.get(pageNum).size(); i++){
        elements.get(pageNum).get(i).setValue(value);
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
        if(hitbox.insideRect(mouseX, mouseY)) {
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

    public boolean insideRect(float xPos, float yPos){
        return (xPos >= x - w / 2 && xPos <= x + w / 2) && (yPos >= y - h / 2 && yPos <= y + h / 2);
    }

    public float[] getComponents(){
        float[] components = {x, y, w, h};
        return components;
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
