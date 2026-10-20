package com.ddwellers.app;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.forwardedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class QgiitPageControllerTest {
    private final MockMvc mvc = MockMvcBuilders.standaloneSetup(new QgiitPageController()).build();

    @Test
    void redirectsToCanonicalDirectory() throws Exception {
        mvc.perform(get("/qgiit"))
                .andExpect(status().isFound())
                .andExpect(redirectedUrl("/qgiit/"));
    }

    @Test
    void servesHomepageWithinQgiitPath() throws Exception {
        mvc.perform(get("/qgiit/"))
                .andExpect(status().isOk())
                .andExpect(forwardedUrl("/qgiit/index.html"));
    }
}
