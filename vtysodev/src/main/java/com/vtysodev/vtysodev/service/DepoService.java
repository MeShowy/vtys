package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.Depo;
import com.vtysodev.vtysodev.repository.DepoRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DepoService {

    @Autowired
    private DepoRepository depoRepository;


    public List<Depo> getDepoList() {
        return depoRepository.getDepoList();
    }


    public Boolean saveDepo(Depo depo) {
        depoRepository.saveDepo(depo.ilceNo, depo.depoAdi, depo.kapasite);
        return true;
    }


    public Depo updateDepo(Depo depo) {
        depoRepository.updateDepo(depo.depoId, depo.ilceNo, depo.depoAdi, depo.kapasite);
        return depoRepository.getDepo(depo.depoId)
                .orElseThrow(() -> new EntityNotFoundException("Depo bulunamadı!"));
    }
}
