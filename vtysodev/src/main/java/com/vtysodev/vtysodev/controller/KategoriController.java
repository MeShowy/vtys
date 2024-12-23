package com.vtysodev.vtysodev.controller;


import com.vtysodev.vtysodev.model.Kategori;
import com.vtysodev.vtysodev.service.KategoriService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("api/kategori")
@RequiredArgsConstructor
public class KategoriController {
    @Autowired
    private KategoriService kategoriService;

    @GetMapping
    public List<Kategori> getKategori(){
        return kategoriService.getKategori();
    }
}
