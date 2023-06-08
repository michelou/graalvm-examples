package dev.danvega;

import java.lang.reflect.InvocationTargetException;

public class Application {

    public static void main(String[] args) throws ClassNotFoundException, NoSuchMethodException,
    InvocationTargetException, InstantiationException, IllegalAccessException {
        Class<?> clazz = Class.forName("dev.danvega." + args[0]);
        clazz.getMethod("printMessage").invoke(clazz.getConstructor().newInstance());
    }

}
