package com.vtysodev.vtysodev.service;


import com.vtysodev.vtysodev.model.Il;
import com.vtysodev.vtysodev.model.Ilce;
import com.vtysodev.vtysodev.repository.IlRepository;
import com.vtysodev.vtysodev.repository.IlceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class IlIlceService {
    @Autowired
    private IlRepository ilRepository;

    @Autowired
    private IlceRepository ilceRepository;

    public List<Il> getIller(){
        return ilRepository.getIller();
    }

    public List<Ilce> getIlceler(){
        return ilceRepository.getIlceler();
    }
}
