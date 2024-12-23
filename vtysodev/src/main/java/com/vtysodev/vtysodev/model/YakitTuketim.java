package com.vtysodev.vtysodev.model;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

import java.sql.Timestamp;

@Table(name = "urun",schema = "public")
@Data
@Entity
public class YakitTuketim {

    @Id
    public Integer kayitId;

    public Integer aracId;

    public Timestamp tarih;

    public Integer gidilenMesafe;

    public Integer tuketilenYakit;

    public Integer yakitMaliyet;

    public Integer yakitFiyati;
}
