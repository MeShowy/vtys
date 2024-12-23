package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.Sevkiyat;
import com.vtysodev.vtysodev.repository.SevkiyatRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SevkiyatService {

    @Autowired
    private SevkiyatRepository sevkiyatRepository;

    // Sevkiyat listesini getir
    public List<Sevkiyat> getSevkiyatList() {
        return sevkiyatRepository.getSevkiyatList();
    }

    // Yeni sevkiyat ekle
    public Boolean saveSevkiyat(Sevkiyat sevkiyat) {
        sevkiyatRepository.saveSevkiyat(
                sevkiyat.siparisNo, sevkiyat.depoId, sevkiyat.aracId, sevkiyat.tarih
        );
        return true;
    }

    // Sevkiyat güncelle
    public Sevkiyat updateSevkiyat(Sevkiyat sevkiyat) {
        sevkiyatRepository.updateSevkiyat(
                sevkiyat.siparisNo, sevkiyat.depoId, sevkiyat.aracId, sevkiyat.tarih
        );
        return sevkiyatRepository.getSevkiyat(
                sevkiyat.siparisNo, sevkiyat.depoId, sevkiyat.aracId, sevkiyat.tarih
        ).orElseThrow(() -> new EntityNotFoundException("Sevkiyat bulunamadı!"));
    }
}
