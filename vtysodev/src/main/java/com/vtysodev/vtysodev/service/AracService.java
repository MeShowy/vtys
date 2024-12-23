package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.Arac;
import com.vtysodev.vtysodev.repository.AracRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service

public class AracService {
    @Autowired
    private AracRepository aracRepository;

    public List<Arac> getAraclar() {
        return aracRepository.getAracList();
    }

    public Boolean saveArac(Arac arac) {
        aracRepository.saveArac(arac.aracTipi);
        return true;
    }

    public Arac updateArac(Arac arac) {

        aracRepository.updateArac(arac.aracId, arac.aracTipi);

        Arac updatedArac;

        updatedArac = aracRepository.getArac(arac.aracId).orElseThrow(()-> new EntityNotFoundException("Arac"));

        return updatedArac;
    }

    public Boolean deleteArac(Integer siparisNo) {
        aracRepository.deleteArac(siparisNo);
        return true;
    }
}
