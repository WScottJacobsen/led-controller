class Effect{
    static final int SOLID = 0, RB_WAVE = 1, RB_SOLID = 2, RB_PULSE = 3, WANDER = 4, USA = 5, MUSIC = 6, VIDEO = 7, BREATHE = 8, BLINK = 9, OFF = 10;
    private final int[] globalEffects = {BREATHE, BLINK, OFF}; //A global effect is one that can be applied on top of another effect
    private Strip strip;
    private int blinkStart = Integer.MIN_VALUE, prevPulse = Integer.MIN_VALUE, prevMovement = Integer.MIN_VALUE, pulsePos = 0, prevColor = 0, prevUpdate = 0, startWidth = 0;
    private boolean blinking = false;
    private float tempBrightness = 0, maxVol = 0.00001;
    private int[] musicColors;

    Effect(Strip s){
        strip = s;
        musicColors = new int[strip.length() / 2];
        //setAll(0x9E3EE8); //Start with arbitrary color
    }
    
    //Effect to run when no other effects are present (only at startup)
    void start(){
        int speed = 10;
        if(millis() >= speed + prevUpdate){
            prevUpdate = millis();
            startWidth++;
            startWidth = constrain(startWidth, 0, strip.length() / 2);
            setAll(0x000000);
            colorMode(HSB, 100);
            for(int i = 0; i < startWidth; i++){
                int rightIndex = strip.length() / 2 + i;
                int leftIndex = strip.length() / 2 - i - 1;
                strip.set(rightIndex, color(map(rightIndex, strip.length() / 2, strip.length(), 0, 100), 100, 100));
                strip.set(leftIndex, color(map(leftIndex, 0, strip.length() / 2, 0, 100), 100, 100));
            }
            colorMode(RGB, 255);
        }
    }

    void fromID(int id, float[] settings){
        switch(id){
            case SOLID: setAll((int)settings[0]); break; //Setting: color
            case RB_WAVE: rbWave(settings); break; //Settings: rainbow speed, position
            case RB_SOLID: rbSolid(settings); break; //Setting: rainbow speed, position
            case RB_PULSE: rbPulse(settings); break; //Setting: speed, position
            case WANDER: wander(); break;
            case USA: usa(settings); break; //Setting: frequency, position
            case MUSIC: music(settings); break; //Setting: volume
            case VIDEO: video(); break;
            case BREATHE: breathe(settings); break;  //Setting: speed, pos, max brightness
            case BLINK: blink(settings); break;  //Setting: blink length, blink delay
            case OFF: off(); break;
        }
    }

    boolean isGlobal(int id){
        for(int i = 0; i < globalEffects.length; i++){
            if(globalEffects[i] == id){
                return true;
            }
        }
        return false;
    }

    void resetMaxVol(){
        maxVol = 0;
    }

//=========================== HELPER FUNCTIONS ===========================//

    private int rgbToHex(int r, int g, int b){
        return ((r & 0xFF) << 16) + ((g & 0xFF) << 8) + (b & 0xFF);
    }

    private int[] hexToRgb(int col){
        int r = ((col >> 16) & 0xFF);
        int g = ((col >> 8) & 0xFF);
        int b = ((col) & 0xFF);
        int[] result = {r, g, b};
        return result;
    }

    private int getRainbowColor(float frequency, float position){
        // Uses three out of sync sin waves to have a smooth transition between colors
        //Frequency is how quickly it moves throught the rainbow
        //Position is where in the rainbow it is
        int red = (int)(sin(frequency * position) * 127 + 128);
        int green = (int)(sin(frequency * position + 2 * PI / 3) * 127 + 128);
        int blue = (int)(sin(frequency * position + 4 * PI / 3) * 127 + 128);
        return rgbToHex(red, green, blue);
    }

    private void setAll(int col){
        for(int i = 0; i < strip.length(); i++){
            strip.set(i, col);
        }
    }

//=============================== EFFECTS ==============================//

    void rbWave(float[] settings){
        float freq = settings[0];
        int pos = (int)settings[1];
        for(int i = 0; i < strip.length(); i++){
            strip.set(i, getRainbowColor(freq, i + pos));
        }
    }

    void rbSolid(float[] settings){
        float freq = settings[0];
        int pos = (int)settings[1];
        setAll(getRainbowColor(freq, pos));
    }

    void rbPulse(float[] settings){
        int speed = (int)settings[0];
        //                         red      orange    yellow    green      blue     indigo    violet
        int[] rainbowColors = {0xFF0000, 0xFFA500, 0xFFFF00, 0x00FF00, 0x0000FF, 0x4B0082, 0xEE82EE};
        if(millis() >= prevPulse + speed){
            int col = rainbowColors[pulsePos % rainbowColors.length];
            pulsePos++;
            setAll(col);
            prevPulse = millis();
        }
    }

    void wander(){
        // Get current color of each pixel, change it to hsb, increment hue value, convert back to rgb and set color
        colorMode(RGB);
        for(int i = 0; i < strip.length(); i++){
            int tempCol = strip.getColor(i);
            int[] rgb = hexToRgb(tempCol);
            color col = color(rgb[0], rgb[1], rgb[2]);
            colorMode(HSB);
            col = color(hue(col) + 2, saturation(col), brightness(col));
            colorMode(RGB);
            strip.set(i, col);
        }
    }

    void usa(float[] settings){
        int freq = (int)settings[0];
        int pos = (int)settings[1];
        //                Red       White     Blue
        int[] colors = {0xFF0000, 0xFFFFFF, 0x0000FF};
        int colorInd = 0;
        int col;
        for(int i = 0; i < strip.length() / freq; i++){
            col = colors[colorInd];
            for(int j = 0; j < freq; j++){
                strip.set((i * freq + j + pos) % strip.length(), col);
            }
            colorInd++;
            colorInd %= colors.length;
        }
    }

    void music(float settings[]){
        int speed = (int)(1 / settings[0] * 1000);
        float vol = settings[1];
        maxVol = vol > maxVol ? vol : maxVol;
        int bandLength = (int)map(vol, 0, maxVol, 1, strip.length() / 2);

        if(millis() >= prevMovement + speed){
            prevColor = musicColors[0];
            colorMode(HSB, 255);
            int col = color(map(bandLength, 0, strip.length() / 2, 0, 255), 255, 255);
            float r = (red(col) + red(prevColor)) / 2.0;
            float g = (green(col) + green(prevColor)) / 2.0;
            float b = (blue(col) + blue(prevColor)) / 2.0;
            colorMode(RGB, 255);
            col = color(r, g, b);
            prevMovement = millis();
            for(int i = musicColors.length - 2; i >= 0; i--){ //Shift colors to the right, then add new color
                musicColors[i + 1] = musicColors[i];
            }
            musicColors[0] = col;
        }
        setAll(0);
        for(int i = 0; i < bandLength; i++){
            strip.set(strip.length() / 2 - i - 1, musicColors[i]);
            strip.set(strip.length() / 2 + i, musicColors[i]);
        }
    }

    void video(){
        Robot screenReader = null;
		try {
			screenReader = new Robot();
		} catch (AWTException e) {
			println(e);
		}
		Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        int w = screenSize.width, h = screenSize.height;
		BufferedImage sc = screenReader.createScreenCapture(new java.awt.Rectangle(w, h));
        long totalR = 0, totalG = 0, totalB = 0;
        int[] rgb;
        for(int i = 0; i < w; i+=100){
            for(int j = 0; j < h; j+=100){
                rgb = hexToRgb(sc.getRGB(i, j));
                totalR += rgb[0];
                totalG += rgb[1];
                totalB += rgb[2];
            }
        }
        totalR /= w / 100 * h / 100;
        totalG /= w / 100 * h / 100;
        totalB /= w / 100 * h / 100;
        int col = rgbToHex((int)totalR, (int)totalG, (int)totalB);
        setAll(col);
    }

    void breathe(float[] settings){
        float freq = settings[0];
        int pos = (int)settings[1];
        float maxBrightness = settings[2];
        float brightness = map(sin(freq * pos), -1, 1, 0, maxBrightness);
        strip.setBrightness(brightness);
    }

    void blink(float[] settings){
        int blinkLength = (int)settings[0];
        int blinkDelay = (int)settings[1];
        if(!blinking && millis() >= blinkStart + blinkDelay){
            tempBrightness = strip.getBrightness();
            blinkStart = millis();
            blinking = true;
            strip.setBrightness(0);
        } else if(blinking && millis() <= blinkLength + blinkStart){
            strip.setBrightness(0);
        } else if(blinking){
            blinkStart = millis();
            blinking = false;
            strip.setBrightness(tempBrightness);
        }
    }

    void off(){
        strip.setBrightness(0);
    }
}