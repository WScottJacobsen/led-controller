class Strip{
    private int ledCount;
    private float brightness;
    private int[] leds;
    private long clockSpeed;

    Strip(int ledCount){
        this.ledCount = ledCount;
        this.leds = new int[ledCount];
        this.clockSpeed = 800000;
        this.brightness = 50.0;
    }

    Strip(int ledCount, long clockSpeed){
        this.ledCount = ledCount;
        this.leds = new int[ledCount];
        this.clockSpeed = clockSpeed;
        this.brightness = 50.0;
    }

    int length(){
        return ledCount;
    }

    void init(Serial port){
        port.write(ledCount + ";");
        port.write(clockSpeed + ";");
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
