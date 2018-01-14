class Rectangle{
    private float x, y, w, h;

    Rectangle(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    void set(float x, float y, float w, float h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    boolean insideRect(float xPos, float yPos){
        return (xPos >= x - w / 2 && xPos <= x + w / 2) && (yPos >= y - h / 2 && yPos <= y + h / 2);
    }

    float[] getComponents(){
        float[] components = {x, y, w, h};
        return components;
    }
}
