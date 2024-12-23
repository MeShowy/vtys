package com.vtysodev.vtysodev.model;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

import java.sql.Timestamp;

@Table(name = "fatura",schema = "public")
@Data
@Entity
public class Fatura {
    @Id
    public Integer faturaNo;

    public Timestamp faturaTarihi;
}
