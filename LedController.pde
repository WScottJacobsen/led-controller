//TODO: Add sliders

ArrayList<ArrayList<InputElement>> elements; //Holds all buttons and sliders, each ArrayList<InputElement> represents a "page"
int numPages = 4; //Total number of pages
final int MAIN_MENU = 0, EFFECTS = 1, EFFECT_SETTINGS = 2, LED_SETTINGS = 3;
int pageNumber = MAIN_MENU; //Page that is visible
Style BUTTON_STYLE;
float titleHeight = 50.0;

//Initialize variables and create and align InputElements
void setup() {
    size(800, 800);
    rectMode(CENTER); //Draw rectangles from the center point
    BUTTON_STYLE = new Style(#000000, #FFFFFF, #FFFFFF, #000000, #000000, 2, createFont("mononoki.ttf", 16, true), 16); //Black text on white background with black outline, inverted colors when hovered, mononoki font at 16px

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

//Where the InputElements and their effects are created
void addElements(ArrayList<ArrayList<InputElement>> elements){
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
