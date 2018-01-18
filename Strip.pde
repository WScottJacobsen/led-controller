class Strip{
    private int ledCount;
    private float brightness;
    private int[] leds;

    Strip(int ledCount){
        this.ledCount = ledCount;
        this.leds = new int[ledCount];
        this.brightness = 50.0;
    }

    int length(){
        return ledCount;
    }

    void set(int pixel, int col){
        leds[pixel] = col;
    }

    int getColor(int pixel){
        return leds[pixel];
    }

    void setBrightness(float brightness){
        this.brightness = brightness;
    }

    float getBrightness(){
        return brightness;
    }

    void update(Serial port){
        String output = "";
        int[] colors = applyBrightness();
        int r = 255, g = 0, b = 0;
        for(int i = 0; i < ledCount; i++){
            int col = colors[i];
            r = (col >> 16 & 0xFF);
            g = (col >> 8 & 0xFF);
            b = (col & 0xFF);
            output += r + "," + g + "," + b + "\n";
        }
        //println(output);
        port.write(output);
    }

    int[] applyBrightness(){
        int[] temp = new int[ledCount];
        colorMode(HSB, 100);
        for(int i = 0; i < ledCount; i++){
            temp[i] = color(hue(leds[i]), saturation(leds[i]), brightness);
        }
        colorMode(RGB, 255);
        return temp;
    }
}
