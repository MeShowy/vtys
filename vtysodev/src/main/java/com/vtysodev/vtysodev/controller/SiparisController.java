package com.vtysodev.vtysodev.controller;

import com.vtysodev.vtysodev.model.Sevkiyat;
import com.vtysodev.vtysodev.model.Siparis;
import com.vtysodev.vtysodev.service.SevkiyatService;
import com.vtysodev.vtysodev.service.SiparisService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.sql.Date;
import java.util.List;

@RestController
@RequestMapping("api/siparis")
@RequiredArgsConstructor
public class SiparisController {

    @Autowired
    private SiparisService siparisService;

    @Autowired
    private SevkiyatService sevkiyatService;

    // Sipariş listesini getir
    @GetMapping
    public List<Siparis> getSiparisler() {
        return siparisService.getSiparisList();
    }

    @GetMapping("/durum")
    public String durumOgren(@RequestParam Integer siparisNo, @RequestParam Date tarih){
        return siparisService.siparisDurumOgren(siparisNo, tarih);
    }

    @GetMapping("/siparisSirala")
    public List<?> durumOgren(@RequestParam Integer siparisVeren){
        return siparisService.siparisSirala(siparisVeren);
    }

    @GetMapping("/stokKontrol")
    public String stokKontrolOgren(@RequestParam Integer urunKodu){
        return siparisService.stokDurumKontrol(urunKodu);
    }

    @GetMapping("/urunCikar")
    public String urunCikar(@RequestParam Integer urunKodu,@RequestParam Integer miktar){
        return siparisService.urunCikar(urunKodu, miktar);
    }


    // Yeni sipariş ekle
    @PostMapping
    public Boolean addSiparis(@RequestBody Siparis siparis) {
        return siparisService.saveSiparis(siparis);
    }

    // Sipariş güncelle
    @PutMapping
    public Siparis updateSiparis(@RequestBody Siparis siparis) {
        return siparisService.updateSiparis(siparis);
    }

    @DeleteMapping("{siparisNo}")
    public Boolean deleteSiparis(@PathVariable("siparisNo") Integer siparisNo) {
        return siparisService.deleteSiparisurun(siparisNo);
    }

    // Sevkiyat listesini getir
    @GetMapping("/sevkiyat")
    public List<Sevkiyat> getSevkiyatlar() {
        return sevkiyatService.getSevkiyatList();
    }

    // Yeni sevkiyat ekle
    @PostMapping("/sevkiyat")
    public Boolean addSevkiyat(@RequestBody Sevkiyat sevkiyat) {
        return sevkiyatService.saveSevkiyat(sevkiyat);
    }

    // Sevkiyat güncelle
    @PutMapping("/sevkiyat")
    public Sevkiyat updateSevkiyat(@RequestBody Sevkiyat sevkiyat) {
        return sevkiyatService.updateSevkiyat(sevkiyat);
    }
}
