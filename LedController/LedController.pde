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
    //Align the elements of all pages
    for(int i = 0; i < numPages; i++){
        alignToGrid(elements.get(i), 50, 10, 1); //Align with 50px of padding, 10px of element padding, and with 1 column
    }
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
    elements.get(MAIN_MENU).add(new Button("Effects", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                jumpTo(EFFECTS);
            }
            public void secondaryAction() {
                primaryAction();
            }
        }
    ));

    elements.get(MAIN_MENU).add(new Button("Effect Settings", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                jumpTo(EFFECT_SETTINGS);
            }
            public void secondaryAction() {
                primaryAction();
            }
        }
    ));

    elements.get(MAIN_MENU).add(new Button("LED Strip Settings", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                jumpTo(LED_SETTINGS);
            }
            public void secondaryAction() {
                primaryAction();
            }
        }
    ));

//=========================== EFFECTS PAGE ===========================//
    elements.get(EFFECTS).add(new Button("Rainbow Wave", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                println("left clicked");
            }
            public void secondaryAction() {
                println("right clicked");
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Solid Rainbow", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                println("left clicked");
            }
            public void secondaryAction() {
                println("right clicked");
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Pulse Rainbow", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                println("left clicked");
            }
            public void secondaryAction() {
                println("right clicked");
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Wander v1", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                println("left clicked");
            }
            public void secondaryAction() {
                println("right clicked");
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("Wander v2", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                println("left clicked");
            }
            public void secondaryAction() {
                println("right clicked");
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("USA", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                println("left clicked");
            }
            public void secondaryAction() {
                println("right clicked");
            }
        }
    ));

    elements.get(EFFECTS).add(new Button("BACK TO MAIN MENU", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                jumpTo(MAIN_MENU);
            }
            public void secondaryAction() {
                primaryAction();
            }
        }
    ));

//=========================== EFFECT SETTINGS PAGE ===========================//
    elements.get(EFFECT_SETTINGS).add(new Button("BACK TO MAIN MENU", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                jumpTo(MAIN_MENU);
            }
            public void secondaryAction() {
                primaryAction();
            }
        }
    ));

//=========================== LED SETTINGS PAGE ===========================//
    elements.get(LED_SETTINGS).add(new Button("Breathe", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                println("left clicked");
            }
            public void secondaryAction() {
                println("right clicked");
            }
        }
    ));

    elements.get(LED_SETTINGS).add(new Button("Blink", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                println("left clicked");
            }
            public void secondaryAction() {
                println("right clicked");
            }
        }
    ));
    elements.get(LED_SETTINGS).add(new Button("BACK TO MAIN MENU", BUTTON_STYLE, true,
        new ButtonAction(){
            @Override
            public void primaryAction() {
                jumpTo(MAIN_MENU);
            }
            public void secondaryAction() {
                primaryAction();
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
