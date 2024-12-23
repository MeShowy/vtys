package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.Kategori;
import com.vtysodev.vtysodev.repository.KategoriRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class KategoriService {
    @Autowired
    private KategoriRepository kategoriRepository;

    public List<Kategori> getKategori(){
        return kategoriRepository.getKategori();
    }

}
