package org.graalvm.example;

import java.util.Date;

import static org.junit.Assert.*;
import org.junit.Test;

public class HelloCachedTimeJUnitTest {

    @Test
    public void test() {
        Date now = new Date();
        assertEquals("Startup versus now time", Startup1.TIME, now);
    }

}
