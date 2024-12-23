package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.Calisan;
import com.vtysodev.vtysodev.repository.CalisanRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CalisanService {

    @Autowired
    private CalisanRepository calisanRepository;

    // Çalışan listesini getir
    public List<Calisan> getCalisanList() {
        return calisanRepository.getCalisanList();
    }

    // Yeni çalışan ekle
    public Boolean saveCalisan(Calisan calisan) {
        calisanRepository.saveCalisan(
                calisan.calisanId, calisan.bolumId, calisan.ad, calisan.soyad, calisan.gorevTuru,
                calisan.maas, calisan.departman, calisan.deneyim, calisan.aracId, calisan.AracTipi
        );
        return true;
    }

    // Çalışan güncelle
    public Calisan updateCalisan(Calisan calisan) {
        calisanRepository.updateCalisan(
                calisan.calisanId, calisan.bolumId, calisan.ad, calisan.soyad, calisan.gorevTuru,
                calisan.maas, calisan.departman, calisan.deneyim, calisan.aracId, calisan.AracTipi
        );
        return calisanRepository.getCalisan(calisan.calisanId)
                .orElseThrow(() -> new EntityNotFoundException("Çalışan bulunamadı!"));
    }
}
