package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.Tedarikci;
import com.vtysodev.vtysodev.model.Urun;
import com.vtysodev.vtysodev.repository.TedarikciRepository;
import com.vtysodev.vtysodev.repository.UrunRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UrunService {
    @Autowired
    private TedarikciRepository tedarikciRepository;

    @Autowired
    private UrunRepository urunRepository;

    public List<Tedarikci> getTedarikci(){
        return tedarikciRepository.getTedarikci();
    }

    public List<Urun> getUrunList() {
        return urunRepository.getUrunList();
    }

    public Boolean saveUrun(Urun urun) {
        urunRepository.saveUrun(urun.urunKodu, urun.urunAdi, urun.stok, urun.kategoriId, urun.birimFiyat);
        return true;
    }

    public Urun updateUrun(Urun urun) {
        urunRepository.updateUrun(urun.urunKodu, urun.urunAdi, urun.stok, urun.kategoriId, urun.birimFiyat);
        return urunRepository.getUrun(urun.urunKodu)
                .orElseThrow(() -> new EntityNotFoundException("Ürün bulunamadı!"));
    }
}



