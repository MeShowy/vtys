package com.vtysodev.vtysodev.model;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Table(name = "siparis",schema = "public")
@Data
@Entity
public class Siparis {

    public Integer urunKodu;

    public String siparisAdi;

    @Id
    public Integer siparisNo;

    public Integer birimFiyat;

    public Integer faturaNo;

    public Integer siparisAdet;

    public Integer tutar;

    public Integer siparisVeren;
}
