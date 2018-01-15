import java.util.Scanner;

ArrayList<ArrayList<InputElement>> elements; //Holds all buttons and sliders, each ArrayList<InputElement> represents a "page"
int numPages = 4; //Total number of pages
final int MAIN_MENU = 0, EFFECTS = 1, EFFECT_SETTINGS = 2, LED_SETTINGS = 3;
int pageNumber = MAIN_MENU; //Page that is visible
Style INPUT_STYLE;
float titleHeight = 50.0;

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

    //Algin elements to grid
    int[] menuLayout = {1, 1, 1, 2};
    alignToGrid(elements.get(MAIN_MENU), 50, 10, menuLayout); //Align with 50px of padding, 10px of element padding, and with 1 columns

    alignToGrid(elements.get(EFFECTS), 50, 10, 3); //Align with 50px of padding, 10px of element padding, and with 3 columns

    int[] effectSettingsLayout = {1, 3, 1, 1, 1};
    alignToGrid(elements.get(EFFECT_SETTINGS), 50, 10, effectSettingsLayout); //Align with 50px of padding, 10px of element padding, and with 1 columns

    int[] ledSettingsLayout = {2, 2, 1};
    alignToGrid(elements.get(LED_SETTINGS), 50, 10, ledSettingsLayout); //Align with 50px of padding, 10px of element padding, and with 1 columns

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
    elements.get(EFFECTS).add(new Button("Rainbow Wave", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Solid Rainbow", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Pulse Rainbow", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Wander", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("USA", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Music Reactive", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Video Reactive", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
                resetSelected(EFFECTS, 0);
				clicked();
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Solid Color", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
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

    elements.get(EFFECT_SETTINGS).add(new Slider("Solid Color Red Channel", "", 1, 0, 255, 0, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Solid Color Green Channel", "", 1, 0, 255, 0, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Solid Color Blue Channel", "", 1, 0, 255, 255, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Music Sensitivity", "%", 1, 0, 100, 50, INPUT_STYLE, true));

    elements.get(EFFECT_SETTINGS).add(new Slider("Rainbow Speed (higher is faster)", "", 100, 0.01, 3.14, 0.1, INPUT_STYLE, true));

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
                println("clicked");
				clicked();
            }
        }
    ));

    elements.get(LED_SETTINGS).add(new Button("Blink", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
				clicked();
            }
        }
    ));

    elements.get(LED_SETTINGS).add(new Slider("Brightness", "%", 10, 0, 100, 50, INPUT_STYLE, true));

    elements.get(LED_SETTINGS).add(new Button("Strip On", INPUT_STYLE, true, true,
        new ButtonAction(){
            @Override
            public void execute() {
                println("clicked");
				clicked();
            }
        }
    ));
    elements.get(LED_SETTINGS).get(elements.get(LED_SETTINGS).size() - 1).setValue(1);

    elements.get(LED_SETTINGS).add(new Button("BACK TO MAIN MENU", INPUT_STYLE, true, false,
        new ButtonAction(){
            @Override
            public void execute() {
                jumpTo(MAIN_MENU);
            }
        }
    ));
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
    for(int i = 0; i < elements.get(pageNum).size(); i++){
        elements.get(pageNum).get(i).setValue(value);
    }
}
