package com.vtysodev.vtysodev.service;

import com.vtysodev.vtysodev.model.Fatura;
import com.vtysodev.vtysodev.repository.FaturaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FaturaService {

    @Autowired
    private FaturaRepository faturaRepository;

    public List<Fatura> getFatura(){
        return faturaRepository.getFaturaList();
    }






}
