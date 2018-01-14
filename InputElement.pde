interface InputElement{
    void checkMouse(); //Check if intersecting with hitbox, preform action when necessary
    void render(); //Draws element
    void setEnabled(boolean value); //Changes if user can interact with element
    boolean isEnabled(); //Checks if user can interact with element
    void setBox(float x, float y, float w, float h); //Change hitbox for element
    void setClicked(boolean value); //Tells whether or not to wait to new click before performing action
    float getValue(); //Returns value of element, 0 is false, everything else is true
    void setValue(float value); //Sets value of element
}
