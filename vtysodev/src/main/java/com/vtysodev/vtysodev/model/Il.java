package com.vtysodev.vtysodev.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Table(name = "il",schema = "public")
@Data
@Entity
public class Il {
    @Id
    @Column(name = "il_adi")
    public String ilAdi;

    @Column(name = "il_no")
    public Integer ilNo;
}
