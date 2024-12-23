package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.Fatura;
import com.vtysodev.vtysodev.model.Siparis;
import com.vtysodev.vtysodev.repository.FaturaRepository;
import com.vtysodev.vtysodev.repository.SiparisRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class SiparisService {

    @Autowired
    private SiparisRepository siparisRepository;

    @Autowired
    private FaturaRepository faturaRepository;

    // Sipariş listesini getir
    public List<Siparis> getSiparisList() {
        return siparisRepository.getSiparisList();
    }

    // Yeni sipariş ekle
    public Boolean saveSiparis(Siparis siparis) {
        LocalDateTime localDateTime = LocalDateTime.now();
        faturaRepository.saveFatura(localDateTime);
        Fatura fatura = faturaRepository.getLastFatura();
        siparisRepository.saveSiparis(
                siparis.siparisNo, siparis.urunKodu, siparis.siparisAdi, siparis.birimFiyat,
                fatura.faturaNo, siparis.siparisAdet, siparis.tutar, siparis.siparisVeren
        );
        return true;
    }

    // Sipariş güncelle
    public Siparis updateSiparis(Siparis siparis) {
        siparisRepository.updateSiparis(
                siparis.siparisNo, siparis.urunKodu, siparis.siparisAdi, siparis.birimFiyat,
                siparis.faturaNo, siparis.siparisAdet, siparis.tutar, siparis.siparisVeren
        );
        return siparisRepository.getSiparis(siparis.siparisNo)
                .orElseThrow(() -> new EntityNotFoundException("Sipariş bulunamadı!"));
    }

    public Boolean deleteSiparisurun(Integer siparisNo) {
        siparisRepository.deleteSiparisurun(siparisNo);
        return true;
    }

    public String siparisDurumOgren(Integer siparisNo, Date tarih){
        return siparisRepository.siparisDurumOgren(siparisNo, tarih);
    }

    public List<?> siparisSirala(Integer siparisVeren){
        return siparisRepository.siparisVerilen(siparisVeren);
    }

    public String stokDurumKontrol(Integer urunKodu){
        return siparisRepository.stokDurumKontrol(urunKodu);
    }

    public String urunCikar(Integer urunKodu, Integer miktar){
        return siparisRepository.urunCikar(urunKodu, miktar);
    }
}
