package com.ddwellers.app;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class QgiitPageController {

    @GetMapping("/qgiit")
    public String canonicalPath() {
        return "redirect:/qgiit/";
    }

    @GetMapping("/qgiit/")
    public String homepage() {
        return "forward:/qgiit/index.html";
    }
}
