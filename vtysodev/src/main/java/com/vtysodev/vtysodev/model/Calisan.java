package com.vtysodev.vtysodev.model;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Table(name = "calisan",schema = "Calisan")
@Entity
@Data
public class Calisan {
    @Id
    public Integer calisanId;

    public Integer bolumId;

    public String ad;

    public String soyad;

    public String gorevTuru;

    public Integer maas;

    public String departman;

    public Integer deneyim;

    public Integer aracId;

    public String AracTipi;
}
