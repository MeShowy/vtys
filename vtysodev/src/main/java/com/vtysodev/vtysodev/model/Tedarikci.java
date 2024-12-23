package com.vtysodev.vtysodev.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Table(name = "kategori",schema = "public")
@Data
@Entity
public class Tedarikci {

    @Id
    @Column(name = "tedarikci_id")
    public Integer tedarikciId;

    @Column(name = "ilce_no")
    public Integer ilceNo;

    @Column(name = "kategori_id")
    public Integer kategoriId;

    @Column(name = "telefon_no")
    public String telefonNo;

    @Column(name = "ad")
    public String ad;


}
