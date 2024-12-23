package com.vtysodev.vtysodev.controller;

import com.vtysodev.vtysodev.model.Depo;
import com.vtysodev.vtysodev.model.DepoBakim;
import com.vtysodev.vtysodev.model.DepoBolum;
import com.vtysodev.vtysodev.service.DepoBakimService;
import com.vtysodev.vtysodev.service.DepoBolumService;
import com.vtysodev.vtysodev.service.DepoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/depo")

public class DepoController {



    @Autowired
    private DepoService depoService;

    @Autowired
    private DepoBakimService depoBakimService;

    @Autowired
    private DepoBolumService depoBolumService;

    @GetMapping
    public List<Depo> getDepolar() {
        return depoService.getDepoList();
    }


    @PostMapping
    public Boolean addDepo(@RequestBody Depo depo) {
        depoService.saveDepo(depo);
        return true;
    }

    @PutMapping
    public Depo updateDepo(@RequestBody Depo depo) {
        return depoService.updateDepo(depo);
    }

    @GetMapping("/bakim")
    public List<DepoBakim> getDepoBakimlar() {
        return depoBakimService.getDepoBakimList();
    }


    @PostMapping("/bakim")
    public Boolean addDepoBakim(@RequestBody DepoBakim depoBakim) {
        depoBakimService.saveDepoBakim(depoBakim);
        return true;
    }


    @PutMapping("/bakim")
    public DepoBakim updateDepoBakim(@RequestBody DepoBakim depoBakim) {
        return depoBakimService.updateDepoBakim(depoBakim);
    }

    @GetMapping("/bolum")
    public List<DepoBolum> getDepoBolumlar() {
        return depoBolumService.getDepoBolumList();
    }

    @PostMapping("/bolum")
    public Boolean addDepoBolum(@RequestBody DepoBolum depoBolum) {
        depoBolumService.saveDepoBolum(depoBolum);
        return true;
    }

    @PutMapping("/bolum")
    public DepoBolum updateDepoBolum(@RequestBody DepoBolum depoBolum) {
        return depoBolumService.updateDepoBolum(depoBolum);
    }
}
