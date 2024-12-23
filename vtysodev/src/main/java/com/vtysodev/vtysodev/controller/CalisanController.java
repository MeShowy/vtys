package com.vtysodev.vtysodev.controller;

import com.vtysodev.vtysodev.model.Calisan;
import com.vtysodev.vtysodev.service.CalisanService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/calisan")
@RequiredArgsConstructor
public class CalisanController {

    @Autowired
    private CalisanService calisanService;

    // Çalışan listesini getir
    @GetMapping
    public List<Calisan> getCalisanlar() {
        return calisanService.getCalisanList();
    }

    // Yeni çalışan ekle
    @PostMapping
    public Boolean addCalisan(@RequestBody Calisan calisan) {
        return calisanService.saveCalisan(calisan);
    }

    // Çalışan güncelle
    @PutMapping
    public Calisan updateCalisan(@RequestBody Calisan calisan) {
        return calisanService.updateCalisan(calisan);
    }
}
