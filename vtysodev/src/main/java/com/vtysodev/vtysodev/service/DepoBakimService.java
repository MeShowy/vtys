package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.DepoBakim;
import com.vtysodev.vtysodev.repository.DepoBakimRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DepoBakimService {

    @Autowired
    private DepoBakimRepository depoBakimRepository;

    public List<DepoBakim> getDepoBakimList() {
        return depoBakimRepository.getDepoBakimList();
    }

    public Boolean saveDepoBakim(DepoBakim depoBakim) {
        depoBakimRepository.saveDepoBakim(depoBakim.depoId, depoBakim.bakimMaliyet, depoBakim.bakimTur, depoBakim.bakimTarih);
        return true;
    }

    public DepoBakim updateDepoBakim(DepoBakim depoBakim) {
        depoBakimRepository.updateDepoBakim(depoBakim.depoId, depoBakim.bakimMaliyet, depoBakim.bakimTur, depoBakim.bakimTarih);
        return depoBakimRepository.getDepoBakim(depoBakim.depoId)
                .orElseThrow(() -> new EntityNotFoundException("Depo Bakım kaydı bulunamadı!"));
    }
}
