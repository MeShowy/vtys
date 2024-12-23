package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.YakitTuketim;
import com.vtysodev.vtysodev.repository.YakitTuketimRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class YakitTuketimService {

    @Autowired
    private YakitTuketimRepository yakitTuketimRepository;

    // Yakıt tüketim kayıtlarını getir
    public List<YakitTuketim> getYakitTuketimList() {
        return yakitTuketimRepository.getYakitTuketimList();
    }

    // Yeni yakıt tüketim kaydı ekle
    public Boolean saveYakitTuketim(YakitTuketim yakitTuketim) {
        yakitTuketimRepository.saveYakitTuketim(
                yakitTuketim.kayitId, yakitTuketim.aracId, yakitTuketim.tarih,
                yakitTuketim.gidilenMesafe, yakitTuketim.tuketilenYakit, yakitTuketim.yakitFiyati
        );
        return true;
    }

    // Yakıt tüketim kaydını güncelle
    public YakitTuketim updateYakitTuketim(YakitTuketim yakitTuketim) {
        yakitTuketimRepository.updateYakitTuketim(
                yakitTuketim.kayitId, yakitTuketim.aracId, yakitTuketim.tarih,
                yakitTuketim.gidilenMesafe, yakitTuketim.tuketilenYakit, yakitTuketim.yakitFiyati
        );
        return yakitTuketimRepository.getYakitTuketim(yakitTuketim.kayitId)
                .orElseThrow(() -> new EntityNotFoundException("Yakıt tüketim kaydı bulunamadı!"));
    }
}
