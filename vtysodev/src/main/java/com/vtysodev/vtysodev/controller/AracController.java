package com.vtysodev.vtysodev.controller;


import com.vtysodev.vtysodev.model.Arac;
import com.vtysodev.vtysodev.model.YakitTuketim;
import com.vtysodev.vtysodev.repository.AracRepository;
import com.vtysodev.vtysodev.service.AracService;
import com.vtysodev.vtysodev.service.YakitTuketimService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/arac")
@RequiredArgsConstructor
public class AracController {
    @Autowired
    private AracService aracService;
    @Autowired
    private YakitTuketimService yakitTuketimService;


    @GetMapping
    public List<Arac> getAraclar(){
        return aracService.getAraclar();
    }

    @PostMapping
    public Boolean addArac(@RequestBody Arac arac){
        aracService.saveArac(arac);
        return true;
    }

    @PutMapping
    public Arac updateArac(@RequestBody Arac arac){
        return aracService.updateArac(arac);
    }

    @DeleteMapping("{aracId}")
    public Boolean deleteArac(@PathVariable Integer aracId){
        return aracService.deleteArac(aracId);
    }

    // Yakıt tüketim kayıtlarını getir
    @GetMapping("/yakit")
    public List<YakitTuketim> getYakitTuketimler() {
        return yakitTuketimService.getYakitTuketimList();
    }

    // Yeni yakıt tüketim kaydı ekle
    @PostMapping("/yakit")
    public Boolean addYakitTuketim(@RequestBody YakitTuketim yakitTuketim) {
        return yakitTuketimService.saveYakitTuketim(yakitTuketim);
    }

    // Yakıt tüketim kaydını güncelle
    @PutMapping("/yakit")
    public YakitTuketim updateYakitTuketim(@RequestBody YakitTuketim yakitTuketim) {
        return yakitTuketimService.updateYakitTuketim(yakitTuketim);
    }
}
