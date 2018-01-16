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

    void setBox(float x, float y, float w, float h){
        totalHitbox.set(x, y, w, h);
        generateBoxes();
    }

    void setValue(float value){
        this.value = value;
        float[] tabComponents = tab.getComponents();
        float[] components = totalHitbox.getComponents();
        float x = components[0];
        float w = components[2];
        float xPos = map(value, min, max, x - w / 2, x + w / 2);
        tab.set(xPos, tabComponents[1], tabComponents[2], tabComponents[3]);
    }

    float getValue(){
        return value;
    }

    void setEnabled(boolean val){
        this.enabled = val;
    }

    boolean isEnabled(){
        return enabled;
    }

    void setClicked(boolean val){
        this.clicked = val;
    }

    void checkMouse(){
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

    void render(){
        color txtColor = style.getTextColor(), bgColor = style.getBackgroundColor();
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
