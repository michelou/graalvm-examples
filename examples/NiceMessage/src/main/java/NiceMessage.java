package dev.danvega;

public class NiceMessage implements Message {

    @Override
    public void printMessage() {
        System.out.println("This is a nice message!");
    }

}
