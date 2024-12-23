package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.DepoBolum;
import com.vtysodev.vtysodev.repository.DepoBolumRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DepoBolumService {

    @Autowired
    private DepoBolumRepository depoBolumRepository;


    public List<DepoBolum> getDepoBolumList() {
        return depoBolumRepository.getDepoBolumList();
    }


    public Boolean saveDepoBolum(DepoBolum depoBolum) {
        depoBolumRepository.saveDepoBolum(depoBolum.depoId, depoBolum.kategoriId, depoBolum.kapasite, depoBolum.bolumAdi);
        return true;
    }


    public DepoBolum updateDepoBolum(DepoBolum depoBolum) {
        depoBolumRepository.updateDepoBolum(depoBolum.bolumId, depoBolum.depoId, depoBolum.kategoriId, depoBolum.kapasite, depoBolum.bolumAdi);
        return depoBolumRepository.getDepoBolum(depoBolum.bolumId)
                .orElseThrow(() -> new EntityNotFoundException("Depo Bölüm kaydı bulunamadı!"));
    }
}
