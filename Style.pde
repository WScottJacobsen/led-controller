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

    void Style(int txtColor, int txtHover, int bgColor, int bgHover, PFont font, int fontSize){
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

    boolean hasStroke(){
        return stroke;
    }

    int getStrokeColor(){
        return strokeColor;
    }

    int getStrokeWeight(){
        return strokeWeight;
    }

    int getTextColor(){
        return txtColor;
    }

    int getTextHover(){
        return txtHover;
    }

    int getBackgroundColor(){
        return bgColor;
    }

    int getBackgroundHover(){
        return bgHover;
    }

    PFont getFont(){
        return font;
    }

    int getFontSize(){
        return fontSize;
    }
}
