package com.vtysodev.vtysodev.controller;


import com.vtysodev.vtysodev.model.Il;
import com.vtysodev.vtysodev.model.Ilce;
import com.vtysodev.vtysodev.service.IlIlceService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/ililce")
@RequiredArgsConstructor
public class IlceIlController {

    @Autowired
    private IlIlceService ilIlceService;

    @GetMapping("/iller")
    public List<Il> getIller(){
        return ilIlceService.getIller();
    }

    @GetMapping("/ilceler")
    public List<Ilce> getIlceler(){
        return ilIlceService.getIlceler();
    }
}
