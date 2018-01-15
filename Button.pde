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

    float getValue(){
        return toggled ? 1 : 0;
    }

    void setValue(float value){
        toggled = value == 0 ? false : true;
    }

    void checkMouse(){
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

    void setBox(float x, float y, float w, float h){
        hitbox.set(x, y, w, h);
    }

    void setEnabled(boolean value){
        enabled = value;
    }

    boolean isEnabled(){
        return enabled;
    }

    void setClicked(boolean value){
        clicked = value;
    }

    void render(){
        color txtColor = style.getTextColor(), bgColor = style.getBackgroundColor();
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
