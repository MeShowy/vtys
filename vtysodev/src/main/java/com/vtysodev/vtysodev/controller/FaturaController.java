package com.vtysodev.vtysodev.controller;

import com.vtysodev.vtysodev.model.Fatura;
import com.vtysodev.vtysodev.service.FaturaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/fatura")
public class FaturaController {

    @Autowired
    private FaturaService faturaService;

    @GetMapping
    public List<Fatura> getFatura() {
        return faturaService.getFatura();
    }
}
