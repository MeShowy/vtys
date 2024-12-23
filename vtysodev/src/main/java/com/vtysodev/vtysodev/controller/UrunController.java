package com.vtysodev.vtysodev.controller;

import com.vtysodev.vtysodev.model.Tedarikci;
import com.vtysodev.vtysodev.model.Urun;
import com.vtysodev.vtysodev.service.UrunService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/urun")
@RequiredArgsConstructor
public class UrunController {

    @Autowired
    private UrunService urunService;

    @GetMapping
    public List<Urun> getUrunler() {
        return urunService.getUrunList();
    }

    @PostMapping
    public Boolean addUrun(@RequestBody Urun urun) {
        return urunService.saveUrun(urun);
    }

    @PutMapping
    public Urun updateUrun(@RequestBody Urun urun) {
        return urunService.updateUrun(urun);
    }

    @GetMapping("/tedarikci")
    public List<Tedarikci> getTedarikci(){
        return urunService.getTedarikci();
    }
}
