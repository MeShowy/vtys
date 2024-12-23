package com.vtysodev.vtysodev.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Table(name = "kategori",schema = "public")
@Data
@Entity
public class Kategori {

    @Id
    @Column(name = "kategori_id")
    public Integer kategoriId;

    @Column(name = "kategori_adi")
    public String kategoriAdi;
}
